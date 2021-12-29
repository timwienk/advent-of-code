#!/usr/bin/python
import os
import sys

path = os.path.join(os.path.dirname(__file__), sys.argv[1] if len(sys.argv) > 1 else 'input')

instructions = []
for line in open(path, 'r'):
    instruction = line.strip().split(' ')
    if len(instruction) == 3 and instruction[2] not in ('w', 'x', 'y', 'z'):
        instruction[2] = int(instruction[2])
    instructions.append(tuple(instruction))

class ALU:
    def __init__(self, instructions):
        self.instructions = []
        for function, *arguments in instructions:
            if function == 'inp':
                current_instructions = [(function, *arguments)]
                self.instructions.append(current_instructions)
            else:
                current_instructions.append((function, *arguments))

    def run(self, number):
        # inp w      -> w = w
        # mul x 0    -> x = 0
        # add x z    -> x = z
        # mod x 26   -> x = z%26
        # div z var1 -> z = z // var1
        # add x var2 -> x = var2 + z%26
        # eql x w    -> x = (w == (var2 + z%26))
        # eql x 0    -> x = (w != (var2 + z%26))
        # mul y 0    -> y = 0
        # add y 25   -> y = 25
        # mul y x    -> y = 25 * (w != (var2 + z%26))
        # add y 1    -> y = 1 + 25 * (w != (var2 + z%26))
        # mul z y    -> z = (z // var1) * (1 + 25 * (w != (var2 + z%26)))
        # mul y 0    -> y = 0
        # add y w    -> y = w
        # add y var3 -> y = var3 + w
        # mul y x    -> y = (var3 + w) * (w != (var2 + z%26))
        # add z y    -> z = (var3 + w) * (w != (var2 + z%26)) + (z // var1) * (1 + 25 * (w != (var2 + z%26)))
        digits = [int(n) for n in str(number)]
        z = 0
        for i, w in enumerate(digits):
            var1 = self.instructions[i][4][2]
            var2 = self.instructions[i][5][2]
            var3 = self.instructions[i][15][2]

            x = var2 + z%26
            #z = (var3 + w) * (w != x) + (z // var1) * (1 + 25 * (w != x))
            if w != x:
                z = (var3 + w) + (z // var1) * 26
            else:
                z = (z // var1)

        assert z == self._run(number)
        return z

    def run_partial(self, digits):
        # Observation:
        # * `z` is increased when `w` is not equal to `var2 + z%26`.
        # * `z` is decreased when `w` is equal to `var2 + z%26`.
        # * `w` is always an input digit, and can only have a value in the range 1-10.
        # * `w` can only equal `var2 + z%26` when `var2` is below 10.
        # * There are 7 values of `var2` above 10, and 7 values for `var2` below 10.
        # Assumption:
        # * `z` is increased 7 times (when `var2` is above 10).
        # * To get `z` to 0, we need it decreased 7 times too (when `var2` is below 10).
        # So:
        # * When `var2` is below 10, we pass None for `w` and just set it to `var2 + z%26`
        # * When that doesn't return a valid value for `w` (1-10), we can stop trying for these digits
        # * Brute force try all digits for which `var2` is not below 10
        # * We expect `w != x` in these cases, increasing `z`
        number = 0

        z = 0
        for i, w in enumerate(digits):
            var1 = self.instructions[i][4][2]
            var2 = self.instructions[i][5][2]
            var3 = self.instructions[i][15][2]

            x = var2 + z%26
            if w is None:
                if 0 < x < 10:
                    w = x
                    z = (z // var1)
                else:
                    z = 1
                    break
            elif w != x:
                z = (z // var1) * 26 + (var3 + w)
            else:
                z = (z // var1)
                assert False, 'Expected w != x'

            number = number * 10 + w

        if z != 0:
            number = None
        else:
            assert self.run(number) == z

        return number

    def find_highest_model_number(self):
        digits = [None if instructions[5][2] < 10 else 9 for instructions in self.instructions]

        number = None
        while number is None:
            number = self.run_partial(digits)

            if number is None:
                for i in reversed(range(len(digits))):
                    if digits[i] is not None:
                        if digits[i] > 1:
                            digits[i] -= 1
                            break
                        elif i == 0:
                            number = False
                        else:
                            digits[i] = 9

        return number

    def find_lowest_model_number(self):
        digits = [None if instructions[5][2] < 10 else 1 for instructions in self.instructions]

        number = None
        while number is None:
            number = self.run_partial(digits)

            if number is None:
                for i in reversed(range(len(digits))):
                    if digits[i] is not None:
                        if digits[i] < 9:
                            digits[i] += 1
                            break
                        elif i == 0:
                            number = False
                        else:
                            digits[i] = 1

        return number

    def _run(self, number):
        self.registers = {
            'w': 0,
            'x': 0,
            'y': 0,
            'z': 0,
        }

        self.digits = [int(n) for n in reversed(str(number))]
        for instructions in self.instructions:
            for function, *arguments in instructions:
                getattr(self, function)(*arguments)

        return self.registers['z']

    def inp(self, a):
        self.registers[a] = self.digits.pop()

    def add(self, a, b):
        if isinstance(b, str):
            b = self.registers[b]
        self.registers[a] += b

    def mul(self, a, b):
        if isinstance(b, str):
            b = self.registers[b]
        self.registers[a] *= b

    def div(self, a, b):
        if isinstance(b, str):
            b = self.registers[b]
        assert b != 0
        self.registers[a] //= b

    def mod(self, a, b):
        if isinstance(b, str):
            b = self.registers[b]
        assert self.registers[a] >= 0
        assert b > 0
        self.registers[a] %= b

    def eql(self, a, b):
        if isinstance(b, str):
            b = self.registers[b]
        self.registers[a] = int(self.registers[a] == b)

alu = ALU(instructions)

answer1 = alu.find_highest_model_number()
answer2 = alu.find_lowest_model_number()

print('--- Day 24: Arithmetic Logic Unit ---')
print(' Answer 1: ' + str(answer1))
print(' Answer 2: ' + str(answer2))
