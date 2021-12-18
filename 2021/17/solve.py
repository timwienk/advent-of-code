#!/usr/bin/python
import os
import sys

path = os.path.join(os.path.dirname(__file__), sys.argv[1] if len(sys.argv) > 1 else 'input')

with open(path, 'r') as f:
    area = {}
    for target in f.readline().strip().replace('target area: ', '').split(', '):
        area[target[0]] = tuple(int(coordinate) for coordinate in target[2:].split('..'))

def calculate_x(velocity, step):
    # x = velocity × step - (sum of deceleration until previous step)
    # x = velocity × step - (previous_step × (previous_step + 1) ÷ 2)
    # x = velocity × step - ((step - 1) × step ÷ 2)
    #
    # every step the current velocity decreases by 1 until it reaches 0
    # which means that it reaches 0 when step = initial velocity
    step = min(step, velocity)
    return velocity * step - ((step - 1) * step) // 2

def calculate_y(velocity, step):
    # y = velocity × step - (sum of deceleration until previous step)
    # y = velocity × step - (previous_step × (previous_step + 1) ÷ 2)
    # y = velocity × step - ((step - 1) × step ÷ 2)
    #
    # y is fine to go below 0
    return velocity * step - ((step - 1) * step) // 2

def calculate_min_x_velocity(min_x, max_x):
    # the minimum initial x velocity is the velocity with which the max
    # x position it reaches is the minimum valid x.
    #
    # the max x position is reached when step = initial velocity, which
    # means that we can replace step with velocity in the formula for x.
    #
    #                              max x position = minimum valid x
    #   velocity × step - ((step - 1) × step ÷ 2) = minimum valid x
    # velocity² - ((velocity - 1) × velocity ÷ 2) = minimum valid x
    #    velocity² - ((velocity² - velocity) ÷ 2) = minimum valid x
    #  (2 × velocity² - velocity² - velocity) ÷ 2 = minimum valid x
    #                  (velocity² - velocity) ÷ 2 = minimum valid x
    #                        velocity² - velocity = 2 × minimum valid x
    #                        velocity - √velocity = √(2 × minimum valid x)
    #                                    velocity = √(2 × minimum valid x) + something
    #
    # meaning we can safely use:         velocity = √(2 × minimum valid x)
    return int((2 * min_x) ** 0.5)

def calculate_max_x_velocity(min_x, max_x):
    # the maximum initial x velocity is when the maximum valid x is
    # reached in 1 step
    return max_x

def calculate_min_y_velocity(min_y, max_y):
    # the minimum initial y velocity is when the minimum valid y is
    # reached in 1 step, assuming all valid y values are below zero
    assert min_y < 0 and max_y < 0
    return min_y

def calculate_max_y_velocity(min_y, max_y):
    # after the max y position, the y velocity accelerates downward at
    # the same rate it previously decelerated (exactly 1 per stap),
    # meaning it will reach y=0 again with the exact opposite velocity
    # of the velocity it started with
    #
    # assuming all valid y values are below zero, the maximum initial y
    # velocity is when the minimum valid y is reached in 1 step after
    # having reached y=0 again, at which point the speed has decreased
    # one more:
    #               current velocity = (minimum valid y) = -velocity - 1
    #                                 -(minimum valid y) =  velocity + 1
    #                             -(minimum valid y) - 1 =  velocity
    #
    # meaning the maximum initial y velocity is the opposite of the
    # minimum, minus 1
    assert min_y < 0 and max_y < 0
    return -1 * min_y - 1

min_x = min(area['x'])
max_x = max(area['x'])
min_y = min(area['y'])
max_y = max(area['y'])

min_vx = calculate_min_x_velocity(min_x, max_x)
max_vx = calculate_max_x_velocity(min_x, max_x)
min_vy = calculate_min_y_velocity(min_y, max_y)
max_vy = calculate_max_y_velocity(min_y, max_y)

answer1 = calculate_y(max_vy, max_vy)
answer2 = 0

for vx in range(min_vx, max_vx + 1):
    for vy in range(min_vy, max_vy + 1):
        # skip to a step larger than 0:
        # - 1: because step 0 is at (0,0)
        # - min_x ÷ vx: the absolute minimum to make it to min_x
        # - 2 × vy + 1: for positive vy, this is the absolute minimum
        step = max(1, min_x // vx, 2 * vy + 1)
        x = 0
        y = 0
        while x <= max_x and y >= min_y:
            x = calculate_x(vx, step)
            y = calculate_y(vy, step)
            step += 1
            if min_x <= x <= max_x and min_y <= y <= max_y:
                answer2 += 1
                break

print('--- Day 17: Trick Shot ---')
print(' Answer 1: ' + str(answer1))
print(' Answer 2: ' + str(answer2))
