#!/usr/bin/python
import os
import sys
from heapq import heappush, heappop

path = os.path.join(os.path.dirname(__file__), sys.argv[1] if len(sys.argv) > 1 else 'input')

tile = {}
for y, line in enumerate(open(path, 'r')):
    for x, risk in enumerate(line.strip()):
        tile[(x, y)] = int(risk)

tilesize = int(len(tile) ** 0.5)
adjacent = [(0, -1), (1, 0), (0, 1), (-1, 0)]

def calculate_risk(tilecount):
    size = tilecount*tilesize
    start = (0, 0)
    goal = (size-1, size-1)

    stack = [(0, start)]
    risks = {start: 0}

    while stack:
        priority, current = heappop(stack)
        if current == goal:
            break

        current_risk = risks[current]
        for x, y in adjacent:
            x += current[0]
            y += current[1]

            if 0 <= x < size and 0 <= y < size:
                neighbour = (x, y)
                risk = current_risk + (tile[(x % tilesize, y % tilesize)] + (x // tilesize) + (y // tilesize) - 1) % 9 + 1

                if neighbour not in risks or risks[neighbour] > risk:
                    risks[neighbour] = risk
                    priority = risk + (sum(goal) - sum(neighbour))
                    heappush(stack, (priority, neighbour))

    return risks[goal]

answer1 = calculate_risk(1)
answer2 = calculate_risk(5)

print('--- Day 15: Chiton ---')
print(' Answer 1: ' + str(answer1))
print(' Answer 2: ' + str(answer2))
