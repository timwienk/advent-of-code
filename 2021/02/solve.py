#!/usr/bin/python
import os
import sys

path = os.path.join(os.path.dirname(__file__), sys.argv[1] if len(sys.argv) > 1 else 'input')

with open(path, 'r') as f:
    commands = [line.strip().split() for line in f.readlines()]

aim = 0
position = 0
depth = 0

for command, amount in commands:
    if command == 'down':
        aim += int(amount)
    elif command == 'up':
        aim -= int(amount)
    elif command == 'forward':
        position += int(amount)
        depth += aim * int(amount)

answer1 = position * aim
answer2 = position * depth

print('--- Day 2: Dive! ---')
print(' Answer 1: ' + str(answer1))
print(' Answer 2: ' + str(answer2))
