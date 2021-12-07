#!/usr/bin/python
import os
import sys
from math import floor, ceil

path = os.path.join(os.path.dirname(__file__), sys.argv[1] if len(sys.argv) > 1 else 'input')

with open(path, 'r') as f:
    numbers = sorted([int(number) for number in f.readline().strip().split(',')])

average = sum(numbers) / len(numbers)

position1 = numbers[len(numbers)//2]
position2 = [floor(average), ceil(average)]

answer1 = 0

averages = [0, 0]
for number in numbers:
    answer1 += abs(position1 - number)

    for i, position in enumerate(position2):
        averages[i] += abs(position - number) * (abs(position - number) + 1) // 2

answer2 = min(averages)

#answer2 = float('inf')
#for position in range(min(numbers), max(numbers)):
#    fuel = 0
#    for number in numbers:
#        fuel += abs(position - number) * (abs(position - number) + 1) // 2
#    if answer2 > fuel:
#        answer2 = fuel

print('--- Day 7: The Treachery of Whales ---')
print(' Answer 1: ' + str(answer1))
print(' Answer 2: ' + str(answer2))
