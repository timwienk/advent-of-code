#!/bin/sh
set -efuC

DIR=`readlink -m \`dirname $0\``
if [ $# -gt 0 ]; then
	FILE="$DIR/$1"
else
	FILE="$DIR/input"
fi

MAX_X=`wc -L < "$FILE"`
MAX_Y=`wc -l < "$FILE"`

count_trees(){
	X=0
	Y=0

	TREES=0

	while [ $Y -lt $MAX_Y ]; do
		X=$(( (X + $1) % MAX_X ))
		Y=$(( Y + $2 ))
		if [ "`dd if="$FILE" status=none ibs=1 count=1 skip=$(( X + Y + Y * MAX_X ))`" = '#' ]; then
			TREES=$(( TREES + 1 ))
		fi
	done

	echo $TREES
}

ANSWER1=`count_trees 3 1`
ANSWER2=$(( `count_trees 1 1` * `count_trees 3 1` * `count_trees 5 1` * `count_trees 7 1` * `count_trees 1 2` ))

echo '--- Day 3: Toboggan Trajectory ---'
echo " Answer 1: $ANSWER1"
echo " Answer 2: $ANSWER2"
