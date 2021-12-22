#!/usr/bin/python
import os
import sys
from itertools import product

path = os.path.join(os.path.dirname(__file__), sys.argv[1] if len(sys.argv) > 1 else 'input')

with open(path, 'r') as f:
    starting_positions = [int(line[28:]) for line in f]

class DeterministicGame:
    dice = 3
    sides = 100

    def __init__(self, starting_positions):
        self.states = [(position, 0) for position in starting_positions]
        self.rolls = 0
        self.winning_score = None
        self.losing_score = None

    def __repr__(self):
        return 'DeterministicGame' + repr(vars(self))

    def move(self, player):
        position, score = self.states[player]

        steps = self.roll() + self.roll() + self.roll()
        position = (position + steps) % 10
        score += (position if position > 0 else 10)

        self.states[player] = (position, score)

        if score >= 1000:
            self.winning_score = score
            self.losing_score = self.states[(player + 1) % 2][1]

    def roll(self):
        self.rolls += 1
        return self.rolls % 100

class QuantumGame:
    dice = 3
    sides = 3

    def __init__(self, starting_positions):
        starting_state = tuple(value for starting_position in starting_positions for value in (starting_position, 0))
        self.states = {starting_state: 1}
        self.winning_score = None
        self.losing_score = None

    def __repr__(self):
        representation = {}
        for key, value in vars(self).items():
            if key == 'states':
                representation[key] = (len(value), sum(count for count in value.values()))
            else:
                representation[key] = value
        return 'QuantumGame' + repr(representation)

    def move(self, player):
        states = {}
        for state, count in self.states.items():
            if state[1] >= 21 or state[3] >= 21:
                if state in states:
                    states[state] += count
                else:
                    states[state] = count
            else:
                position0, score0, position1, score1 = state
                for steps in self.roll():
                    if player == 0:
                        new_position = (position0 + steps) % 10
                        new_score = score0 + (new_position if new_position > 0 else 10)
                        new_state = (new_position, new_score, position1, score1)
                    else:
                        new_position = (position1 + steps) % 10
                        new_score = score1 + (new_position if new_position > 0 else 10)
                        new_state = (position0, score0, new_position, new_score)

                    if new_state in states:
                        states[new_state] += count
                    else:
                        states[new_state] = count

        self.states = states

        if all(state[1] >= 21 or state[3] >= 21 for state in self.states.keys()):
            scores = [0, 0]
            for state, count in self.states.items():
                scores[int(state[1] < state[3])] += count

            self.winning_score = max(scores)
            self.losing_score = min(scores)

    def roll(self):
        return [sum(rolls) for rolls in product(range(1, self.sides + 1), repeat=self.dice)]


game1 = DeterministicGame(starting_positions)
while not game1.winning_score:
    for player in range(2):
        game1.move(player)
        if game1.winning_score:
            break

game2 = QuantumGame(starting_positions)
while not game2.winning_score:
    for player in range(2):
        game2.move(player)
        if game2.winning_score:
            break

answer1 = game1.rolls * game1.losing_score
answer2 = game2.winning_score

print('--- Day 21: Dirac Dice ---')
print(' Answer 1: ' + str(answer1))
print(' Answer 2: ' + str(answer2))
