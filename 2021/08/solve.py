#!/usr/bin/python
import os
import sys

path = os.path.join(os.path.dirname(__file__), sys.argv[1] if len(sys.argv) > 1 else 'input')

entries = []

for line in open(path, 'r'):
    entry = []
    for part in line.strip().split(' | '):
        entry.append([set(characters) for characters in part.split(' ')])
    entries.append(entry)

digits = [
    {'a', 'b', 'c', 'e', 'f', 'g'},
    {'c', 'f'},
    {'a', 'c', 'd', 'e', 'g'},
    {'a', 'c', 'd', 'f', 'g'},
    {'b', 'c', 'd', 'f'},
    {'a', 'b', 'd', 'f', 'g'},
    {'a', 'b', 'd', 'e', 'f', 'g'},
    {'a', 'c', 'f'},
    {'a', 'b', 'c', 'd', 'e', 'f', 'g'},
    {'a', 'b', 'c', 'd', 'f', 'g'},
]

answer1 = len([entry for entry in entries for output in entry[1] if len(output) in (2,3,4,7)])
answer2 = 0

for patterns, output in entries:
    segments = dict(zip(digits[8], [None for segment in digits[8]]))
    patterns.sort(key=len)

    # The smallest pattern is 1, with segments C and F on
    for char in patterns[0]:
        # Segment C is used in 8 digits, segment F is used in 9 digits
        if len([pattern for pattern in patterns if char in pattern]) == 8:
            segments[char] = 'c'
        else:
            segments[char] = 'f'

    # The second smallest pattern is 7, with segments A, C and F on
    for char in patterns[1]:
        # Already found C and F, so whatever remains is segment A
        if segments[char] is None:
            segments[char] = 'a'

    # The third smallest pattern is 4, with segments B, C, D and F on
    for char in patterns[2]:
        # Already found C and F, so whatever remains is segment B or D
        if segments[char] is None:
            # Segment B is used in 6 digits, segment D is used in 7 digits
            if len([pattern for pattern in patterns if char in pattern]) == 6:
                segments[char] = 'b'
            else:
                segments[char] = 'd'

    for char in segments.keys():
        # Already found A, B, C, D and F, so whatever remains is segment E or G
        if segments[char] is None:
            # Segment E is used in 4 digits, segment G is used in 7 digits
            if len([pattern for pattern in patterns if char in pattern]) == 4:
                segments[char] = 'e'
            else:
                segments[char] = 'g'

    decoded = ''
    for chars in output:
        digit = {segments[char] for char in chars}
        decoded += str(digits.index(digit))
    answer2 += int(decoded)

print('--- Day 8: Seven Segment Search ---')
print(' Answer 1: ' + str(answer1))
print(' Answer 2: ' + str(answer2))
