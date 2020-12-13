#!/bin/sh
set -efuC

DIR=`readlink -m \`dirname $0\``
if [ $# -gt 0 ]; then
	FILE="$DIR/$1"
else
	FILE="$DIR/input"
fi

TIME=`head -n1 "$FILE"`
INPUT=`tail -n1 "$FILE"`
IFS=,

BEST_BUS=''
BEST_WAIT=$TIME
for BUS in $INPUT; do
	if [ $BUS != 'x' ]; then
		WAIT=$(( BUS - TIME % BUS ))
		if [ $WAIT -lt $BEST_WAIT ]; then
			BEST_BUS=$BUS
			BEST_WAIT=$WAIT
		fi
	fi
done

TIME=1
SKIP=1
I=0
for BUS in $INPUT; do
	if [ $BUS != 'x' ]; then
		# Each departure should be I minutes after the first.
		# Departures are every BUS minutes, which means:
		# TIME is only valid when TIME+I is dividable by BUS.
		while [ $(( (TIME + I) % BUS )) -ne 0 ]; do
			TIME=$(( TIME + SKIP ))
		done

		# After finding a valid TIME, we only need to try TIMEs where
		# this correct sequence of departures repeats, i.e. TIMEs at
		# which TIME+I remains dividable by BUS.
		# This is true for this BUS and all previous BUSes every
		# SKIP×BUS minutes.
		SKIP=$(( SKIP * BUS ))
	fi

	I=$(( I + 1 ))
done

ANSWER1=$(( BEST_BUS * BEST_WAIT ))
ANSWER2=$TIME

echo '--- Day 13: Shuttle Search ---'
echo " Answer 1: $ANSWER1"
echo " Answer 2: $ANSWER2"
