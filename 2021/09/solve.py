#!/usr/bin/python
import os
import sys

path = os.path.join(os.path.dirname(__file__), sys.argv[1] if len(sys.argv) > 1 else 'input')

heights = {}
for y, line in enumerate(open(path, 'r')):
    for x, height in enumerate(line.strip()):
        heights[(x, y)] = int(height)

adjacent = [(0, -1), (1, 0), (0, 1), (-1, 0)]

answer1 = 0
for coordinates, height in heights.items():
    low = True

    for x, y in adjacent:
        adjacent_coordinates = (x + coordinates[0], y + coordinates[1])
        if adjacent_coordinates in heights and height >= heights[adjacent_coordinates]:
            low = False
            break

    if low:
        answer1 += height + 1

basins = []
checked = set()
for coordinates, height in heights.items():
    if coordinates not in checked and height < 9:
        basin = 0
        stack = {coordinates}

        while stack:
            coordinates = stack.pop()
            checked.add(coordinates)
            basin += 1

            for x, y in adjacent:
                adjacent_coordinates = (x + coordinates[0], y + coordinates[1])
                if adjacent_coordinates in heights and heights[adjacent_coordinates] < 9:
                    if adjacent_coordinates not in checked and adjacent_coordinates not in stack:
                        stack.add(adjacent_coordinates)

        basins.append(basin)

basins.sort(reverse=True)
answer2 = basins[0] * basins[1] * basins[2]

print('--- Day 9: Smoke Basin ---')
print(' Answer 1: ' + str(answer1))
print(' Answer 2: ' + str(answer2))
