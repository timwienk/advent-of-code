#!/bin/sh
set -efuC

DIR=`readlink -m \`dirname $0\``
if [ $# -gt 0 ]; then
	FILE="$DIR/$1"
else
	FILE="$DIR/input"
fi

MASK0=''
MASK1=''
DATA=''
while read LINE; do
	for PART in $LINE; do
		case $PART in
			=) ;;
			mask) ACTION=mask ;;
			mem*) ACTION=mem; ADDRESS=`echo "$PART" | tr -cd 0-9`;;
			*) VALUE=$PART;;
		esac
	done
	case $ACTION in
		mask)
			MASK0=`echo "ibase=2;obase=A;$VALUE" | tr X 1 | bc`
			MASK1=`echo "ibase=2;obase=A;$VALUE" | tr X 0 | bc`
			;;
		mem)
			VALUE=$(( VALUE & MASK0 | MASK1 ))
			DATA="$ADDRESS	$VALUE
$DATA"
			;;
	esac
done < "$FILE"

ANSWER1=`echo -n "$DATA" | sort -usk1n | cut -f2 | paste -sd+ | bc`

MASK1=''
MASKX=''
FLOATING=''
DATA=''
while read LINE; do
	LINEDATA=''
	echo -n '.'
	for PART in $LINE; do
		case $PART in
			=) ;;
			mask) ACTION=mask ;;
			mem*) ACTION=mem; ADDRESS=`echo "$PART" | tr -cd 0-9`;;
			*) VALUE=$PART;;
		esac
	done
	case $ACTION in
		mask)
			MASK1=`echo "ibase=2;obase=A;$VALUE" | tr X 0 | bc`
			MASKX=`echo "ibase=2;obase=A;$VALUE" | tr 0X 10 | bc`
			FLOATING=''
			I=36
			for X in `echo "$VALUE" | fold -w1`; do
				I=$(( I - 1 ))
				if [ "$X" = 'X' ]; then
					FLOATING="$FLOATING $I"
				fi
			done
			;;
		mem)
			ADDRESS=$(( ADDRESS & MASKX | MASK1 ))
			ADDRESSES="$ADDRESS"
			for X in $FLOATING; do
				for ADDRESS in $ADDRESSES; do
					ADDRESSES="$ADDRESSES $(( ADDRESS | (1<<X) ))"
				done
			done
			for ADDRESS in $ADDRESSES; do
				LINEDATA="$ADDRESS	$VALUE
$LINEDATA"
			done
			;;
	esac
	DATA=`echo -n "$LINEDATA$DATA" | sort -usk1n`
done < "$FILE"
echo

ANSWER2=`echo "$DATA" | cut -f2 | paste -sd+ | bc`

echo '--- Day 14: Docking Data ---'
echo " Answer 1: $ANSWER1"
echo " Answer 2: $ANSWER2"
