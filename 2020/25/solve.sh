#!/bin/sh
set -efuC

DIR=`readlink -m \`dirname $0\``
if [ $# -gt 0 ]; then
	FILE="$DIR/$1"
else
	FILE="$DIR/input"
fi

KEY1=''
KEY2=''

while read LINE; do
	if [ -z "$KEY1" ]; then
		KEY1="$LINE"
	else
		KEY2="$LINE"
	fi
done < "$FILE"

LOOPSIZE=0
VALUE=1
while [ $KEY1 -ne $VALUE ]; do
	LOOPSIZE=$(( LOOPSIZE + 1 ))
	echo -n "$LOOPSIZE"
	VALUE=$(( VALUE * 7 % 20201227 ))
done
echo

N=0
ANSWER1=1
while [ $N -lt $LOOPSIZE ]; do
	N=$(( N + 1 ))
	echo -n "$N"
	ANSWER1=$(( ANSWER1 * KEY2 % 20201227 ))
done
echo

ANSWER2=''

echo '--- Day 25: Combo Breaker ---'
echo " Answer 1: $ANSWER1"
echo " Answer 2: $ANSWER2"
