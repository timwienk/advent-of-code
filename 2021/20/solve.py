#!/usr/bin/python
import os
import sys

path = os.path.join(os.path.dirname(__file__), sys.argv[1] if len(sys.argv) > 1 else 'input')

with open(path, 'r') as f:
    algorithm = [int(bit == '#') for bit in f.readline().strip()]
    f.readline()

    image = {}
    for y, line in enumerate(f):
        for x, pixel in enumerate(line.strip()):
            image[(x, y)] = int(pixel == '#')

def enhance(image, iterations):
    edge_pixel = 0
    min_x = 0
    min_y = 0
    max_x = int(len(image) ** 0.5)
    max_y = int(len(image) ** 0.5)

    for iteration in range(iterations):
        enhanced_image = {}

        for x in range(min_x-1, max_x+2):
            for y in range(min_y-1, max_y+2):
                index = 0
                for index_y in (y-1, y, y+1):
                    for index_x in (x-1, x, x+1):
                        index = (index << 1)
                        if (index_x, index_y) in image:
                            index |= image[(index_x, index_y)]
                        else:
                            index |= edge_pixel
                enhanced_image[(x, y)] = algorithm[index]

        image = enhanced_image
        edge_pixel = algorithm[edge_pixel * 511]
        min_x -= 1
        min_y -= 1
        max_x += 1
        max_y += 1

    return image

answer1 = sum(enhance(image, 2).values())
answer2 = sum(enhance(image, 50).values())

print('--- Day 20: Trench Map ---')
print(' Answer 1: ' + str(answer1))
print(' Answer 2: ' + str(answer2))
