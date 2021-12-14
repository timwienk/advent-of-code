#!/usr/bin/python
import os
import sys

path = os.path.join(os.path.dirname(__file__), sys.argv[1] if len(sys.argv) > 1 else 'input')

with open(path, 'r') as f:
    template = f.readline().strip()

    rules = {}
    for line in f:
        line = line.strip()
        if line:
            segment, element = line.split(' -> ')
            rules[segment] = element

segments = {}
for n in range(len(template)):
    segment = template[n:n+2]
    if segment in segments:
        segments[segment] += 1
    else:
        segments[segment] = 1

for n in range(40):
    new_segments = {}
    for segment, count in segments.items():
        if segment not in rules:
            new_segments[segment] = count
        else:
            element = rules[segment]
            for new_segment in (segment[0]+element, element+segment[1]):
                if new_segment in new_segments:
                    new_segments[new_segment] += count
                else:
                    new_segments[new_segment] = count
    segments = new_segments

    if n == 9 or n == 39:
        elements = {}
        for segment, count in segments.items():
            element = segment[0]
            if element in elements:
                elements[element] += count
            else:
                elements[element] = count
            if n == 9:
                answer1 = max(elements.values()) - min(elements.values())
            else:
                answer2 = max(elements.values()) - min(elements.values())

print('--- Day 14: Extended Polymerization ---')
print(' Answer 1: ' + str(answer1))
print(' Answer 2: ' + str(answer2))
