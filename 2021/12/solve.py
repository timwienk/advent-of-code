#!/usr/bin/python
import os
import sys

path = os.path.join(os.path.dirname(__file__), sys.argv[1] if len(sys.argv) > 1 else 'input')

adjacent = {}
for line in open(path, 'r'):
    cave1, cave2 = line.strip().split('-')

    if cave1 != 'end' and cave2 != 'start':
        if cave1 in adjacent:
            adjacent[cave1].add(cave2)
        else:
            adjacent[cave1] = {cave2}

    if cave2 != 'end' and cave1 != 'start':
        if cave2 in adjacent:
            adjacent[cave2].add(cave1)
        else:
            adjacent[cave2] = {cave1}

answer1 = 0
answer2 = 0

stack = [('start', set(), True)]
while stack:
    cave, visited, allow_second_visit = stack.pop()

    if cave.islower():
        visited = {*visited, cave}

    for adjacent_cave in adjacent[cave]:
        if adjacent_cave == 'end':
            if allow_second_visit:
                answer1 += 1
            answer2 += 1
        elif adjacent_cave not in visited:
            stack.append((adjacent_cave, visited, allow_second_visit))
        elif allow_second_visit:
            stack.append((adjacent_cave, visited, False))

print('--- Day 12: Passage Pathing ---')
print(' Answer 1: ' + str(answer1))
print(' Answer 2: ' + str(answer2))
