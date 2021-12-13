#!/usr/bin/python
import os
import sys

path = os.path.join(os.path.dirname(__file__), sys.argv[1] if len(sys.argv) > 1 else 'input')

dots = set()
folds = None

with open(path, 'r') as f:
    for line in f:
        line = line.strip()
        if not line:
            folds = []
        elif folds is None:
            x, y = line.split(',')
            dots.add((int(x), int(y)))
        else:
            axis, value = line.strip().replace('fold along ', '').split('=')
            folds.append((axis, int(value)))

answer1 = None

for axis, value in folds:
    new_dots = set()
    for x, y in dots:
        if axis == 'x' and x > value:
            new_dots.add((value - (x-value), y))
        elif axis == 'y' and y > value:
            new_dots.add((x, value - (y-value)))
        else:
            new_dots.add((x, y))
    dots = new_dots
    if answer1 is None:
        answer1 = len(dots)

# Print "ASCII art" version of answer 2
for y in range(max([coordinates[1] for coordinates in dots]) + 1):
    line = ''
    for x in range(max([coordinates[0] for coordinates in dots]) + 1):
        if (x, y) in dots:
            line += '#'
        else:
            line += ' '
    print(line)

# Attempt to identify characters by (probable) counts of dots per line
characters = {
    (5, 2, 2, 2, 5, 0): '□',
    (2, 2, 2, 4, 2, 2): 'A',
    (3, 2, 3, 2, 2, 3): 'B',
    (2, 2, 1, 1, 2, 2): 'C',
    (3, 2, 2, 2, 2, 3): 'D',
    (4, 1, 3, 1, 1, 4): 'E',
    (4, 1, 3, 1, 1, 1): 'F',
    (2, 2, 1, 3, 2, 3): 'G',
    (2, 2, 4, 2, 2, 2): 'H',
    (3, 1, 1, 1, 1, 3): 'I',
    (2, 1, 1, 1, 2, 2): 'J',
#    (2, 2, 2, 2, 2, 2): 'K',
    (1, 1, 1, 1, 1, 4): 'L',
    (2, 4, 2, 2, 2, 2): 'M',
    (2, 3, 3, 2, 2, 2): 'N',
#    (2, 2, 2, 2, 2, 2): 'O',
    (3, 2, 2, 3, 1, 1): 'P',
#    (2, 2, 2, 2, 2, 2): 'Q',
    (3, 2, 2, 3, 2, 2): 'R',
    (3, 1, 2, 1, 1, 3): 'S',
    (4, 1, 1, 1, 1, 1): 'T',
#    (2, 2, 2, 2, 2, 2): 'U',
    (2, 2, 2, 2, 2, 1): 'V',
    (2, 2, 2, 2, 4, 2): 'W',
#    (2, 2, 2, 2, 2, 2): 'X',
    (2, 2, 2, 1, 1, 1): 'Y',
    (4, 1, 1, 1, 1, 4): 'Z',
}

# Extra checks for the characters we can't match by dots per line
character_checks = {
    'K': [(2, 1)],
    'O': [(1, 0), (2, 5)],
    'Q': [(1, 0), (2, 4)],
    'U': [(0, 0), (2, 5)],
    'X': [(2, 2)],
}

answer2 = ''
answer2_error = False
for n in range((max([coordinates[0] for coordinates in dots]) // 5) + 1):
    pattern = tuple(len([dot for dot in dots if dot[0]//5 == n and dot[1] == y]) for y in range(6))

    character = None
    if pattern in characters:
        character = characters[pattern]
    elif pattern == (2, 2, 2, 2, 2, 2):
        for value, checks in character_checks.items():
            if all([(x+5*n, y) in dots for x, y in checks]):
                character = value
                break

    if character:
        answer2 += character
    else:
        answer2 += '_'
        answer2_error = True

if answer2_error:
    answer2 += ' (Incomplete! Try reading the ASCII art printed above.)'

print('--- Day 13: Transparent Origami ---')
print(' Answer 1: ' + str(answer1))
print(' Answer 2: ' + str(answer2))
