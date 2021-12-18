#!/usr/bin/python
import os
import sys
from ast import literal_eval

path = os.path.join(os.path.dirname(__file__), sys.argv[1] if len(sys.argv) > 1 else 'input')

with open(path, 'r') as f:
    numbers = [literal_eval(line.strip()) for line in f.readlines()]

class Number:
    def __init__(self, number, parent=None):
        self.parent = parent
        self.value = None
        self.left = None
        self.right = None

        self.parse(number)

    def __repr__(self):
        if self.value is None:
            representation = repr([self.left, self.right])
        else:
            representation = '(' + repr(self.value) + ')'
        return 'Number' + representation

    def __iter__(self):
        return iter([self.left, self.right])

    def parse(self, number):
        if isinstance(number, int):
            self.value = number
        elif isinstance(number, list):
            self.left, self.right = [Number(n, self) for n in number]
        elif isinstance(number, Number):
            # This happens when add()ing Numbers. It is not hugely
            # efficient to create new Number instances for everything we
            # add, but it preserves the original.
            if number.value is None:
                self.left = Number(number.left, self)
                self.right = Number(number.right, self)
            else:
                self.value = number.value
        else:
            raise Exception('Unsupported argument to Number', number)

        if self.parent is None:
            self.reduce()

    def reduce(self):
        stack = [(0, self)]
        while stack:
            depth, number = stack.pop()
            if number.value is None:
                if depth == 4:
                    number.explode()
                    stack.clear()
                    self.reduce()
                    break
                else:
                    stack.append((depth + 1, number.right))
                    stack.append((depth + 1, number.left))

        stack = [(0, self)]
        while stack:
            depth, number = stack.pop()
            if number.value is not None:
                if number.value >= 10:
                    number.split()
                    stack.clear()
                    self.reduce()
                    break
            else:
                stack.append((depth + 1, number.right))
                stack.append((depth + 1, number.left))

    def explode(self):
        self.explode_left()
        self.explode_right()
        self.left = None
        self.right = None
        self.value = 0

    def explode_left(self):
        left = self.left
        parent = self
        while parent and (parent.left == left or parent.left is None):
            left = parent
            parent = parent.parent

        if parent:
            left = parent.left
            while left.right:
                left = left.right
            left.value += self.left.value

    def explode_right(self):
        right = self.right
        parent = self
        while parent and (parent.right == right or parent.right is None):
            right = parent
            parent = parent.parent

        if parent:
            right = parent.right
            while right.left:
                right = right.left
            right.value += self.right.value

    def split(self):
        value = self.value // 2
        self.left = Number(value, self)
        self.right = Number(self.value - value, self)
        self.value = None

    def add(self, other):
        return Number([self, other])

    def get_magnitude(self):
        magnitude = None
        if self.value is not None:
            magnitude = self.value
        else:
            magnitude = 3 * self.left.get_magnitude() + 2 * self.right.get_magnitude()
        return magnitude

parsed = []
total = None
for number in numbers:
    number = Number(number)
    parsed.append(number)
    if total is None:
        total = number
    else:
        total = total.add(number)

answer1 = total.get_magnitude()
answer2 = 0

for number1 in parsed:
    for number2 in parsed:
        if number1 != number2:
            magnitude = number1.add(number2).get_magnitude()
            if magnitude > answer2:
                answer2 = magnitude

print('--- Day 18: Snailfish ---')
print(' Answer 1: ' + str(answer1))
print(' Answer 2: ' + str(answer2))
