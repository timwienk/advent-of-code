#!/usr/bin/python
import os
import sys

path = os.path.join(os.path.dirname(__file__), sys.argv[1] if len(sys.argv) > 1 else 'input')

octopuses = {}
for y, line in enumerate(open(path, 'r')):
    for x, energy in enumerate(line.strip()):
        octopuses[(x, y)] = int(energy)

adjacent = [(0, -1), (1, -1), (1, 0), (1, 1), (0, 1), (-1, 1), (-1, 0), (-1, -1)]

answer1 = 0
answer2 = None

step = 0
while step < 100 or answer2 is None:
    step += 1
    stack = list(octopuses.keys())

    while stack:
        coordinates = stack.pop()
        if octopuses[coordinates] < 10:
            octopuses[coordinates] += 1
            if octopuses[coordinates] == 10:
                for x, y in adjacent:
                    adjacent_coordinates = (x + coordinates[0], y + coordinates[1])
                    if adjacent_coordinates in octopuses:
                        stack.append(adjacent_coordinates)

    if answer2 is None:
        answer2 = step
    for coordinates, energy in octopuses.items():
        if energy == 10:
            if step <= 100:
                answer1 += 1
            octopuses[coordinates] = 0
        else:
            answer2 = None

print('--- Day 11: Dumbo Octopus ---')
print(' Answer 1: ' + str(answer1))
print(' Answer 2: ' + str(answer2))
