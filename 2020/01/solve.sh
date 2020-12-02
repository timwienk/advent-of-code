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

CACHE1=''
while read N1; do
	CACHE1="$CACHE1 $N1"
	CACHE2=''
	for N2 in $CACHE1; do
		if [ -z "$ANSWER1" -a $(( N1 + N2 )) -eq 2020 ]; then
			ANSWER1=$(( N1 * N2 ))
		fi

		if [ -z "$ANSWER2" ]; then
			CACHE2="$CACHE2 $N2"
			for N3 in $CACHE2; do
				if [ $(( N1 + N2 + N3 )) -eq 2020 ]; then
					ANSWER2=$(( N1 * N2 * N3 ))
					break
				fi
			done
		fi

		if [ -n "$ANSWER1" -a -n "$ANSWER2" ]; then
			break 2
		fi
	done
done < "$FILE"

echo '--- Day 1: Report Repair ---'
echo " Answer 1: $ANSWER1"
echo " Answer 2: $ANSWER2"
