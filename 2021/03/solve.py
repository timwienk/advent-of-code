#!/usr/bin/python
import os
import sys

path = os.path.join(os.path.dirname(__file__), sys.argv[1] if len(sys.argv) > 1 else 'input')

with open(path, 'r') as f:
    numbers = [line.strip() for line in f.readlines()]

gamma = ''
epsilon = ''

o2_numbers = list(numbers)
co2_numbers = list(numbers)

for position in range(len(numbers[0])):
    bits = [number[position] for number in numbers]
    if bits.count('1') >= len(numbers)/2:
        gamma += '1'
        epsilon += '0'
    else:
        gamma += '0'
        epsilon += '1'

    if len(o2_numbers) > 1:
        bits = [number[position] for number in o2_numbers]
        if bits.count('1') >= len(o2_numbers)/2:
            o2_numbers = [number for number in o2_numbers if number[position] == '1']
        else:
            o2_numbers = [number for number in o2_numbers if number[position] == '0']

    if len(co2_numbers) > 1:
        bits = [number[position] for number in co2_numbers]
        if bits.count('1') >= len(co2_numbers)/2:
            co2_numbers = [number for number in co2_numbers if number[position] == '0']
        else:
            co2_numbers = [number for number in co2_numbers if number[position] == '1']

answer1 = int(gamma, 2) * int(epsilon, 2)
answer2 = int(o2_numbers[0], 2) * int(co2_numbers[0], 2)

print('--- Day 3: Binary Diagnostic ---')
print(' Answer 1: ' + str(answer1))
print(' Answer 2: ' + str(answer2))
