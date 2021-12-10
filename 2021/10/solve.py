#!/usr/bin/python
import os
import sys
from functools import reduce

path = os.path.join(os.path.dirname(__file__), sys.argv[1] if len(sys.argv) > 1 else 'input')

with open(path, 'r') as f:
    lines = [line.strip() for line in f.readlines()]

pairs = {
    '(': ')',
    '[': ']',
    '{': '}',
    '<': '>',
}

points = {
    # Part 1:
    ')': 3,
    ']': 57,
    '}': 1197,
    '>': 25137,

    # Part 2:
    '(': 1,
    '[': 2,
    '{': 3,
    '<': 4,
}

answer1 = 0

scores = []
for line in lines:
    stack = []

    for char in line:
        if char in pairs:
            stack.append(char)
        else:
            match = stack.pop()
            if char != pairs[match]:
                answer1 += points[char]
                stack.clear()
                break

    if stack:
        scores.append(reduce(lambda score, char: score * 5 + points[char], reversed(stack), 0))

answer2 = sorted(scores)[len(scores)//2]

print('--- Day 10: Syntax Scoring ---')
print(' Answer 1: ' + str(answer1))
print(' Answer 2: ' + str(answer2))
