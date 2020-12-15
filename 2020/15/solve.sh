#!/bin/sh
set -efuC

DIR=`readlink -m \`dirname $0\``
if [ $# -gt 0 ]; then
	FILE="$DIR/$1"
else
	FILE="$DIR/input"
fi

ANSWER1=''
ANSWER2=''

DATA=''
I=1
for N in `tr ',' ' ' < "$FILE"`; do
	printf '%8d -> %s\n' "$I" "$N"
	DATA="$N $I
$DATA"
	I=$(( I + 1 ))
done

N=0
printf '%8d -> %s\n' "$I" "$N"

while [ $I -lt 2020 ]; do
	echo -n "$I"
	LAST_OCCURRENCE=`echo "$DATA" | sed -n "/^$N /s/^$N //p"`
	if echo "$DATA" | grep -q "^$N "; then
		DATA="`echo "$DATA" | sed "/^$N /s/[0-9]*$/$I/"`"
	else
		DATA="$N $I
$DATA"
	fi
	if [ -z "$LAST_OCCURRENCE" ]; then
		N=0
	else
		N=$(( I - LAST_OCCURRENCE ))
	fi
	I=$(( I + 1 ))
done
printf '%8d -> %s\n' "$I" "$N"

ANSWER1=$N

# This will take a while...
while [ $I -lt 30000000 ]; do
	echo -n "$I"
	LAST_OCCURRENCE=`echo "$DATA" | sed -n "/^$N /s/^$N //p"`
	if echo "$DATA" | grep -q "^$N "; then
		DATA="`echo "$DATA" | sed "/^$N /s/[0-9]*$/$I/"`"
	else
		DATA="$N $I
$DATA"
	fi
	if [ -z "$LAST_OCCURRENCE" ]; then
		N=0
	else
		N=$(( I - LAST_OCCURRENCE ))
	fi
	I=$(( I + 1 ))
done
printf '%8d -> %s\n' "$I" "$N"

ANSWER2=$N

echo '--- Day 15: Rambunctious Recitation ---'
echo " Answer 1: $ANSWER1"
echo " Answer 2: $ANSWER2"
