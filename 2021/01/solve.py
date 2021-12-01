#!/usr/bin/python
import os
import sys

path = os.path.join(os.path.dirname(__file__), sys.argv[1] if len(sys.argv) > 1 else 'input')

with open(path, 'r') as f:
    numbers = [int(line) for line in f.readlines()]

answer1 = 0
answer2 = 0

for i, number in enumerate(numbers):
    if i > 0 and number > numbers[i-1]:
        answer1 += 1

    #if i > 2 and (number + numbers[i-1] + numbers[i-2]) > (numbers[i-1] + numbers[i-2] + numbers[i-3]):
    if i > 2 and number > numbers[i-3]:
        answer2 += 1

print('--- Day 1: Sonar Sweep ---')
print(' Answer 1: ' + str(answer1))
print(' Answer 2: ' + str(answer2))
