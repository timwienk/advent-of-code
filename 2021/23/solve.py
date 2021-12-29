#!/usr/bin/python
import os
import sys

path = os.path.join(os.path.dirname(__file__), sys.argv[1] if len(sys.argv) > 1 else 'input')

with open(path, 'r') as f:
    f.readline()
    hallway = [False if slot in (2, 4, 6, 8) else None for slot in range(f.readline().count('.'))]
    rooms = []
    for line in f:
        if not '#########' in line:
            for room, value in enumerate(line[3:10].split('#')):
                if len(rooms) > room:
                    rooms[room].append(value)
                else:
                    rooms.append([value])

class Diagram:
    known_costs = {}

    cost = {
        'A': 1,
        'B': 10,
        'C': 100,
        'D': 1000
    }

    def __init__(self, rooms, hallway):
        self.hallway = hallway.copy()
        self.rooms = [room.copy() for room in rooms]
        self.moves = []

    def __repr__(self):
        lines = [
            ''.join([value if value else '.' for value in self.hallway])
        ]
        padding = ' ' * ((len(self.hallway) - len(self.rooms) * 2 + 1)//2)
        for n in range(len(self.rooms[0])):
            lines.append(padding + ' '.join([room[n] if room[n] else '.' for room in self.rooms]))
        return '\n'.join(lines)

    def unfold(self):
        assert all(len(room) == 2 for room in rooms), 'Already unfolded'

        folded = [['D', 'D'], ['C', 'B'], ['B', 'A'], ['A', 'C']]
        for room, values in enumerate(folded):
            for n, value in enumerate(values):
                self.rooms[room].insert(n+1, value)

        self.known_costs.clear()

    def done(self):
        return all(self.is_room_done(room) for room in range(len(rooms)))

    def get_room(self, value):
        return ord(value) - 65

    def get_room_adjacent_slot(self, room):
        return 2 + room * 2

    def is_room_open(self, room):
        return all(value in (None, chr(65 + room)) for value in self.rooms[room])

    def is_room_done(self, room):
        return all(value == chr(65 + room) for value in self.rooms[room])

    def is_path_clear(self, slot1, slot2):
        return all(not value for value in self.hallway[min(slot1, slot2):max(slot1, slot2)+1])

    def move_from_room_to_room(self, value, room1, room1_slot, room2):
        assert room1 != room2
        assert self.rooms[room1][room1_slot] == value

        room2_slot = len(self.rooms[room2]) - list(reversed(self.rooms[room2])).index(None) - 1
        assert self.rooms[room2][room2_slot] is None

        cost = (abs(self.get_room_adjacent_slot(room2) - self.get_room_adjacent_slot(room1)) + room1_slot + 1 + room2_slot + 1) * self.cost[value]

        self.rooms[room1][room1_slot] = None
        self.rooms[room2][room2_slot] = value
        return cost

    def move_from_room_to_hallway(self, value, room, room_slot, hallway_slot):
        assert self.rooms[room][room_slot] == value
        assert self.hallway[hallway_slot] is None

        cost = (abs(hallway_slot - self.get_room_adjacent_slot(room)) + room_slot + 1) * self.cost[value]

        self.rooms[room][room_slot] = None
        self.hallway[hallway_slot] = value
        return cost

    def move_from_hallway_to_room(self, value, hallway_slot, room):
        assert self.hallway[hallway_slot] == value

        room_slot = len(self.rooms[room]) - list(reversed(self.rooms[room])).index(None) - 1
        assert self.rooms[room][room_slot] is None

        cost = (abs(hallway_slot - self.get_room_adjacent_slot(room)) + room_slot + 1) * self.cost[value]

        self.hallway[hallway_slot] = None
        self.rooms[room][room_slot] = value
        return cost

    def try_from_room_to_room(self):
        cost = 0
        additional_cost = None
        while additional_cost != 0:
            additional_cost = 0
            for room1, values in enumerate(self.rooms):
                if not self.is_room_done(room1) and not self.is_room_open(room1):
                    room1_exit = self.get_room_adjacent_slot(room1)
                    for room1_slot, value in enumerate(values):
                        if value:
                            room2 = self.get_room(value)
                            if self.is_room_open(room2):
                                room2_entrance = self.get_room_adjacent_slot(room2)
                                if self.is_path_clear(room1_exit, room2_entrance):
                                    additional_cost += self.move_from_room_to_room(value, room1, room1_slot, room2)
                            break
            cost += additional_cost
        return cost

    def try_from_hallway_to_room(self):
        cost = 0
        additional_cost = None
        while additional_cost != 0:
            additional_cost = 0
            for slot, value in enumerate(self.hallway):
                if value:
                    room = self.get_room(value)
                    if self.is_room_open(room):
                        room_entrance = self.get_room_adjacent_slot(room)
                        if slot > room_entrance:
                            if self.is_path_clear(slot - 1, room_entrance):
                                additional_cost += self.move_from_hallway_to_room(value, slot, room)
                        else:
                            if self.is_path_clear(slot + 1, room_entrance):
                                additional_cost += self.move_from_hallway_to_room(value, slot, room)
            cost += additional_cost
        return cost

    def try_from_room_to_hallway(self):
        cost = 0
        if not self.done():
            cost = float('inf')
            for room, values in enumerate(self.rooms):
                if not self.is_room_done(room) and not self.is_room_open(room):
                    room_exit = self.get_room_adjacent_slot(room)
                    for room_slot, value in enumerate(values):
                        if value:
                            for hallway_slot in range(len(self.hallway)):
                                if self.hallway[hallway_slot] != False and self.is_path_clear(room_exit, hallway_slot):
                                    diagram = Diagram(self.rooms, self.hallway)
                                    diagram_cost = diagram.move_from_room_to_hallway(value, room, room_slot, hallway_slot)
                                    diagram_cost += diagram.solve()
                                    if cost > diagram_cost:
                                        cost = diagram_cost
                            break
        return cost

    def solve(self):
        solution = hash(repr(self))
        if solution in self.known_costs:
            cost = self.known_costs[solution]
        else:
            cost = self.try_from_room_to_room()
            cost += self.try_from_hallway_to_room()
            cost += self.try_from_room_to_hallway()
            self.known_costs[solution] = cost
        return cost

diagram = Diagram(rooms, hallway)
answer1 = diagram.solve()

diagram.unfold()
answer2 = diagram.solve()

print('--- Day 23: Amphipod ---')
print(' Answer 1: ' + str(answer1))
print(' Answer 2: ' + str(answer2))
