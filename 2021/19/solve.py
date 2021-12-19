#!/usr/bin/python
import os
import sys
#from itertools import permutations, product

path = os.path.join(os.path.dirname(__file__), sys.argv[1] if len(sys.argv) > 1 else 'input')

scans = []
for line in open(path, 'r'):
    line = line.strip()
    if line:
        if line[:3] == '---':
            scan = set()
            scans.append(scan)
        else:
            scan.add(tuple(int(coordinate) for coordinate in line.split(',')))

#orientations = set()
#for x, y, z in permutations([0, 1, 2]):
#    for rx, ry, rz in product([1, -1], repeat=3):
#        # We only need half of these rx, ry, rz. But which?
#        orientations.add((x, y, z, rx, ry, rz))

orientations = set()
# with 0, 1, 2 as indexes of beacon coordinates:
#     for x, y, z in [(0, 1, 2), (1, 2, 0), (2, 0, 1)]:
#         x  y  z :      Face x: y points up, z points front
#         x  z -y :         90°: z points up, y points back
#         x -y -z :        180°: y points down, z points back
#         x -z  y :        270°: z points down, y points front
#        -x  y -z : Away from x: y points up, z points back
#        -x -z -y :         90°: z points down, y points back
#        -x -y  z :        180°: y points down, z points front
#        -x  z  y :        270°: z points up, y points front
for x, y, z in [(0, 1, 2), (1, 2, 0), (2, 0, 1)]:
    for ry, rz in [(1, 1), (1, -1), (-1, -1), (-1, 1)]:
        if ry == rz: # 0° and 180°
            orientations.add((x, y, z,  1,  ry,  rz))
            orientations.add((x, y, z, -1,  ry, -rz))
        else: # 90° and 270°
            orientations.add((x, z, y,  1,  ry,  rz))
            orientations.add((x, z, y, -1, -ry,  rz))

beacons = set()

class Scanner:
    def __init__(self, number, scan):
        self.number = number
        self.scan = scan
        self.position = None

    def __repr__(self):
        representation = '[' + repr(self.number) + ']'
        if self.position:
            representation += '@' + repr(self.position)
        return 'Scanner' + representation

    def align(self, beacons):
        aligned = False

        if not beacons:
            aligned = True
            self.position = (0, 0, 0)
            for beacon in self.scan:
                beacons.add(beacon)

        elif not self.position:
            for orientation in orientations:
                scan = self.get_scan(*orientation)
                position = self.find_position(scan, beacons)
                if position:
                    aligned = True
                    self.position = position
                    self.scan = set()
                    for x, y, z in scan:
                        beacon = (x + position[0], y + position[1], z + position[2])
                        beacons.add(beacon)
                        self.scan.add(beacon)
                    break

        return aligned

    def get_scan(self, x=0, y=1, z=2, rx=1, ry=1, rz=1):
        scan = []
        for result in self.scan:
            scan.append((result[x] * rx, result[y] * ry, result[z] * rz))
        return scan

    def find_position(self, scan, beacons):
        position = None

        differences = {}
        for scan_x, scan_y, scan_z in scan:
            for beacon_x, beacon_y, beacon_z in beacons:
                difference = (beacon_x - scan_x, beacon_y - scan_y, beacon_z - scan_z)

                if difference in differences:
                    differences[difference] += 1
                else:
                    differences[difference] = 1

                if differences[difference] == 12:
                    position = difference
                    break

            if position:
                break

        return position

scanners = []
for i, scan in enumerate(scans):
    scanners.append(Scanner(i, scan))

todo = len(scanners)
while todo:
    for scanner in scanners:
        if scanner.align(beacons):
            todo -= 1

answer1 = len(beacons)
answer2 = 0

for x1, y1, z1 in [scanner.position for scanner in scanners]:
    for x2, y2, z2 in [scanner.position for scanner in scanners]:
        distance = abs(x1 - x2) + abs(y1 - y2) + abs(z1 - z2)
        if distance > answer2:
            answer2 = distance

print('--- Day 19: Beacon Scanner ---')
print(' Answer 1: ' + str(answer1))
print(' Answer 2: ' + str(answer2))
