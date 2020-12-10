#!/bin/sh
set -efuC

DIR=`readlink -m \`dirname $0\``
if [ $# -gt 0 ]; then
	FILE="$DIR/$1"
else
	FILE="$DIR/input"
fi

INPUT=`sort -n "$FILE"`
INPUT="$INPUT
$(( `echo "$INPUT" | tail -n1` + 3 ))"

DIFF1=0
DIFF3=0

ARRANGEMENTS=1
MAX_DIFFERENCE=0

PREVIOUS=0
for NEXT in $INPUT; do
	DIFFERENCE=$(( NEXT - PREVIOUS ))
	case "$DIFFERENCE" in
		1) DIFF1=$(( DIFF1 + 1));;
		3) DIFF3=$(( DIFF3 + 1));;
	esac

	if [ $DIFFERENCE -eq 1 ]; then
		MAX_DIFFERENCE=$(( MAX_DIFFERENCE + 1 ))
	elif [ $MAX_DIFFERENCE -gt 0 ]; then
		case $MAX_DIFFERENCE in
			1) COMBINATIONS=1;;
			2) COMBINATIONS=2;;
			3) COMBINATIONS=4;;
			4) COMBINATIONS=7;;
			*) echo "Expecting only max differences up to 4" >&2; exit 1;;
		esac
		ARRANGEMENTS=$(( ARRANGEMENTS * COMBINATIONS ))
		MAX_DIFFERENCE=0
	fi

	PREVIOUS=$NEXT
done

ANSWER1=$(( DIFF1 * DIFF3 ))
ANSWER2=$ARRANGEMENTS

echo '--- Day 10: Adapter Array ---'
echo " Answer 1: $ANSWER1"
echo " Answer 2: $ANSWER2"
