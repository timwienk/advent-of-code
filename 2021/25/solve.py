#!/usr/bin/python
import os
import sys

path = os.path.join(os.path.dirname(__file__), sys.argv[1] if len(sys.argv) > 1 else 'input')

east = set()
south = set()
for y, line in enumerate(open(path, 'r')):
    for x, cucumber in enumerate(line.strip()):
        if cucumber == '>':
            east.add((x, y))
        elif cucumber == 'v':
            south.add((x, y))

len_x = x + 1
len_y = y + 1

def move(east, south):
    new_east = set()
    new_south = set()

    for x, y in east:
        coordinates = ((x + 1) % len_x, y)
        if coordinates not in east and coordinates not in south:
            new_east.add(coordinates)
        else:
            new_east.add((x, y))

    for x, y in south:
        coordinates = (x, (y + 1) % len_y)
        if coordinates not in new_east and coordinates not in south:
            new_south.add(coordinates)
        else:
            new_south.add((x, y))

    return new_east, new_south

old_east = None
old_south = None
answer = 0
while east != old_east or south != old_south:
    answer += 1
    old_east, old_south = east, south
    east, south = move(east, south)

print('--- Day 25: Sea Cucumber ---')
print(' Answer: ' + str(answer))
