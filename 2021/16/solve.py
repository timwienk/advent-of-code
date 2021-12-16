#!/usr/bin/python
import os
import sys
from math import prod

path = os.path.join(os.path.dirname(__file__), sys.argv[1] if len(sys.argv) > 1 else 'input')

with open(path, 'r') as f:
    transmission = ''
    for byte in bytes.fromhex(f.readline().strip()):
        transmission += format(byte, '08b')

class Packet:
    def __init__(self, data):
        self.version = int(data[:3], 2)
        self.type = int(data[3:6], 2)
        self.size = 6

        self.value = 0
        self.subpackets = []

        if self.type == 4:
            self.parse_literal_value(data[6:])
        else:
            self.parse_operator(data[6:])

    def __repr__(self):
        return 'Packet' + repr(vars(self))

    def parse_literal_value(self, data):
        while data:
            end, value, data = (data[0] == '0'), int(data[1:5], 2), data[5:]
            self.value = (self.value << 4) | value
            self.size += 5
            if end:
                break

    def parse_operator(self, data):
        if data[0] == '0':
            self.size += 16
            self.parse_mode_0_operator(int(data[1:16], 2), data[16:])
        else:
            self.size += 12
            self.parse_mode_1_operator(int(data[1:12], 2), data[12:])

        if self.type == 0:
            self.value = sum([subpacket.value for subpacket in self.subpackets])
        elif self.type == 1:
            self.value = prod([subpacket.value for subpacket in self.subpackets])
        elif self.type == 2:
            self.value = min([subpacket.value for subpacket in self.subpackets])
        elif self.type == 3:
            self.value = max([subpacket.value for subpacket in self.subpackets])
        elif self.type == 5:
            self.value = int(self.subpackets[0].value > self.subpackets[1].value)
        elif self.type == 6:
            self.value = int(self.subpackets[0].value < self.subpackets[1].value)
        elif self.type == 7:
            self.value = int(self.subpackets[0].value == self.subpackets[1].value)

    def parse_mode_0_operator(self, remaining, data):
        while remaining > 0:
            subpacket = Packet(data)
            self.subpackets.append(subpacket)
            self.size += subpacket.size

            data = data[subpacket.size:]
            remaining -= subpacket.size

    def parse_mode_1_operator(self, remaining, data):
        while remaining > 0:
            subpacket = Packet(data)
            self.subpackets.append(subpacket)
            self.size += subpacket.size

            data = data[subpacket.size:]
            remaining -= 1

    def get_version_sum(self):
        return self.version + sum([subpacket.get_version_sum() for subpacket in self.subpackets])

packet = Packet(transmission)
answer1 = packet.get_version_sum()
answer2 = packet.value

print('--- Day 16: Packet Decoder ---')
print(' Answer 1: ' + str(answer1))
print(' Answer 2: ' + str(answer2))
