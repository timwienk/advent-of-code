#!/usr/bin/python
import os
import sys

path = os.path.join(os.path.dirname(__file__), sys.argv[1] if len(sys.argv) > 1 else 'input')

vents = []

for line in open(path, 'r'):
    vent = []
    for coordinates in line.strip().split(' -> '):
        vent.append(tuple(int(coordinate) for coordinate in coordinates.split(',')))
    vents.append(vent)

map1 = {}
map2 = {}

for vent in vents:
    xmod = (vent[1][0] > vent[0][0]) - (vent[0][0] > vent[1][0])
    ymod = (vent[1][1] > vent[0][1]) - (vent[0][1] > vent[1][1])

    x, y = vent[0]
    while x != (vent[1][0] + xmod) or y != (vent[1][1] + ymod):
        coordinates = (x, y)

        if vent[0][0] == vent[1][0] or vent[0][1] == vent[1][1]:
            if coordinates in map1:
                map1[coordinates] += 1
            else:
                map1[coordinates] = 1

        if coordinates in map2:
            map2[coordinates] += 1
        else:
            map2[coordinates] = 1

        x += xmod
        y += ymod

answer1 = sum(value > 1 for value in map1.values())
answer2 = sum(value > 1 for value in map2.values())

print('--- Day 5: Hydrothermal Venture ---')
print(' Answer 1: ' + str(answer1))
print(' Answer 2: ' + str(answer2))
