#!/usr/bin/python
import os
import sys

path = os.path.join(os.path.dirname(__file__), sys.argv[1] if len(sys.argv) > 1 else 'input')

with open(path, 'r') as f:
    numbers = [int(number) for number in f.readline().strip().split(',')]
    boards = []

    rows = None
    for line in f:
        line = line.strip()
        if line:
            rows.append([[int(number), False] for number in line.strip().split()])
        else:
            rows = []
            boards.append(rows)

total = len(boards)
won = set()

for number in numbers:
    for n, board in enumerate(boards):
        if n not in won:
            change = False
            for y, row in enumerate(board):
                for x, cell in enumerate(row):
                    if cell[0] == number:
                        cell[1] = True
                        change = True
                        break
                if change:
                    break

            if change:
                if all([cell[1] for cell in board[y]]):
                    won.add(n)
                elif all([row[x][1] for row in board]):
                    won.add(n)

                if n in won:
                    if len(won) == 1:
                        answer1 = number * sum([cell[0] for row in board for cell in row if not cell[1]])
                    if len(won) == total:
                        answer2 = number * sum([cell[0] for row in board for cell in row if not cell[1]])

print('--- Day 4: Giant Squid ---')
print(' Answer 1: ' + str(answer1))
print(' Answer 2: ' + str(answer2))
