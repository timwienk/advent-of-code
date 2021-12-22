#!/usr/bin/python
import os
import sys
import resource

path = os.path.join(os.path.dirname(__file__), sys.argv[1] if len(sys.argv) > 1 else 'input')

actions = []
for line in open(path, 'r'):
    action, positions = line.strip().split(' ')
    actions.append((action == 'on', *[tuple(int(value) for value in data[2:].split('..')) for data in positions.split(',')]))

def solve(actions, area=None):
    X = set()
    Y = set()
    Z = set()

    if area:
        X.add(-area)
        Y.add(-area)
        Z.add(-area)
        X.add(area + 1)
        Y.add(area + 1)
        Z.add(area + 1)

    for on, (x1, x2), (y1, y2), (z1, z2) in actions:
        X.add(x1)
        X.add(x2 + 1)
        Y.add(y1)
        Y.add(y2 + 1)
        Z.add(z1)
        Z.add(z2 + 1)

    X = sorted(X)
    Y = sorted(Y)
    Z = sorted(Z)

    cubes = set()
    n = 0
    for on, (x1, x2), (y1, y2), (z1, z2) in actions:
        n += 1
        if area:
            x1 = max(-area, x1)
            y1 = max(-area, y1)
            z1 = max(-area, z1)
            x2 = min(area, x2)
            y2 = min(area, y2)
            z2 = min(area, z2)
        min_x = X.index(x1)
        min_y = Y.index(y1)
        min_z = Z.index(z1)
        max_x = X.index(x2 + 1)
        max_y = Y.index(y2 + 1)
        max_z = Z.index(z2 + 1)
        for x in range(min_x, max_x):
            for y in range(min_y, max_y):
                for z in range(min_z, max_z):
                    if on:
                        cubes.add((x, y, z))
                    else:
                        cubes.discard((x, y, z))

    answer = 0
    for x, y, z in cubes:
        answer += (X[x + 1] - X[x]) * (Y[y + 1] - Y[y]) * (Z[z + 1] - Z[z])

    return answer

answer1 = solve(actions, 50)
answer2 = solve(actions)

print('--- Day 22: Reactor Reboot ---')
print(' Answer 1: ' + str(answer1))
print(' Answer 2: ' + str(answer2))
