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

N_PREV=0
for N in `(echo 'ibase=2;obase=A' && tr 'FBLR' '0101' < "$FILE") | bc | sort -rn`; do
	if [ -z "$ANSWER1" ]; then
		ANSWER1=$N
	fi

	if [ $N_PREV -eq $(( N + 2 )) ]; then
		ANSWER2=$(( N + 1 ))
		break
	else
		N_PREV=$N
	fi
done

echo '--- Day 5: Binary Boarding ---'
echo " Answer 1: $ANSWER1"
echo " Answer 2: $ANSWER2"
