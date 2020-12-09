#!/bin/sh
set -efuC

DIR=`readlink -m \`dirname $0\``
if [ $# -gt 0 ]; then
	FILE="$DIR/$1"
else
	FILE="$DIR/input"
fi

if [ `wc -l < "$FILE"` -lt 25 ]; then
	STACKSIZE=5
else
	STACKSIZE=25
fi

I=0
STACK=''
while read N; do
	if [ $I -lt $STACKSIZE ]; then
		if [ -z "$STACK" ]; then
			STACK=$N
		else
			STACK="$N	$STACK"
		fi
		I=$(( I + 1 ))
	else
		MATCH=''
		for A in $STACK; do
			M=$(( N - A ))
			if [ $M -gt 0 ]; then
				for B in $STACK; do
					if [ $M -eq $B ]; then
						MATCH=1
						break 2
					fi
				done
			fi
		done
		if [ -z "$MATCH" ]; then
			ANSWER1=$N
			break
		fi
		STACK=`echo "$N	$STACK" | cut -f1-$STACKSIZE`
	fi
done < "$FILE"

STACK=''
while read N; do
	if [ $N -ne $ANSWER1 ]; then
		STACK="$STACK	$N"
		SUM=0
		for A in $STACK; do
			SUM=$(( SUM + A ))
		done
		if [ $SUM -eq $ANSWER1 ]; then
			break
		else
			while [ $SUM -gt $ANSWER1 ]; do
				STACK=`echo "$STACK" | cut --complement -f1`
				SUM=0
				for A in $STACK; do
					SUM=$(( SUM + A ))
				done
			done
			if [ $SUM -eq $ANSWER1 ]; then
				break
			fi
		fi
	fi
done < "$FILE"

MIN=$ANSWER1
MAX=0
for N in $STACK; do
	if [ $MIN -gt $N ]; then
		MIN=$N
	fi
	if [ $MAX -lt $N ]; then
		MAX=$N
	fi
done
ANSWER2=$(( $MIN + $MAX ))

echo '--- Day 9: Encoding Error ---'
echo " Answer 1: $ANSWER1"
echo " Answer 2: $ANSWER2"
