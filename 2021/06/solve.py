#!/usr/bin/python
import os
import sys

path = os.path.join(os.path.dirname(__file__), sys.argv[1] if len(sys.argv) > 1 else 'input')

with open(path, 'r') as f:
    numbers = [int(number) for number in f.readline().strip().split(',')]

old_fish = [0 for i in range(7)]
new_fish = [0 for i in range(2)]

for number in numbers:
    old_fish[number] += 1

for day in range(80):
    active = day % 7
    new_fish.insert(0, old_fish[active])
    old_fish[active] += new_fish.pop()

answer1 = sum(old_fish + new_fish)

for day in range(80, 256):
    active = day % 7
    new_fish.insert(0, old_fish[active])
    old_fish[active] += new_fish.pop()

answer2 = sum(old_fish + new_fish)

print('--- Day 6: Lanternfish ---')
print(' Answer 1: ' + str(answer1))
print(' Answer 2: ' + str(answer2))
