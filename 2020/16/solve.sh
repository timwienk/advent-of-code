#!/bin/sh
set -efuC

DIR=`readlink -m \`dirname $0\``
if [ $# -gt 0 ]; then
	FILE="$DIR/$1"
else
	FILE="$DIR/input"
fi

MODE=field

FIELDS=''
TICKET=''
NEARBY=''

N=0
while read LINE; do
	if [ -n "$LINE" ]; then
		if [ "$LINE" = 'your ticket:' ]; then
			MODE=ticket
		elif [ "$LINE" = 'nearby tickets:' ]; then
			MODE=nearby
		else
			case $MODE in
				field)
					FIELD=`echo "$LINE" | sed 's/[^:]*: \([0-9]*\)-\([0-9]*\) or \([0-9]*\)-\([0-9]*\)$/\1,\2,\3,\4/'`
					if [ -z "$FIELDS" ]; then
						FIELDS="$FIELD"
					else
						FIELDS="$FIELDS
	$FIELD"
					fi
					;;
				ticket)
					TICKET="$LINE"
					;;
				nearby)
					if [ -z "$NEARBY" ]; then
						NEARBY="$LINE"
					else
						NEARBY="$NEARBY
	$LINE"
					fi
					;;
			esac
		fi
	fi
	N=$(( N + 1 ))
done < "$FILE"

check_value(){
	VALUE=$1
	shift

	while [ $# -gt 0 ]; do
		LOWER=$1
		UPPER=$2
		shift 2
		if [ $VALUE -ge $LOWER -a $VALUE -le $UPPER ]; then
			return 0
		fi
	done

	return 1
}

ANSWER1=0

VALID_NEARBY=''
for DATA in $NEARBY; do
	IFS=','
	I=0
	VALID=1
	for VALUE in $DATA; do
		I=$(( I + 1 ))
		if ! check_value $VALUE `echo "$FIELDS" | paste -sd,`; then
			ANSWER1=$(( ANSWER1 + VALUE ))
			VALID=''
		fi
	done
	if [ -n "$VALID" ]; then
		if [ -z "$VALID_NEARBY" ]; then
			VALID_NEARBY="$DATA"
		else
			VALID_NEARBY="$DATA
$VALID_NEARBY"
		fi
	fi
done

FIELDCOUNT=`echo "$FIELDS" | wc -l`
DATACOUNT=`echo "$VALID_NEARBY" | wc -l`
N=0
VALID_COLUMN_FIELDS=''
while [ $N -lt $FIELDCOUNT ]; do
	N=$(( N + 1 ))
	VALUES=`echo "$VALID_NEARBY" | cut -d, -f$N`

	I=0
	IFS='
'
	VALID_FIELDS=''
	for FIELD in $FIELDS; do
		IFS='
'
		I=$(( I + 1 ))
		VALID=0
		for VALUE in $VALUES; do
			IFS=','
			if check_value $VALUE $FIELD; then
				VALID=$(( VALID + 1 ))
			else
				continue 2
			fi
		done
		if [ $VALID -eq $DATACOUNT ]; then
			if [ -z "$VALID_FIELDS" ]; then
				VALID_FIELDS=$I
			else
				VALID_FIELDS="$VALID_FIELDS,$I"
			fi
		fi
	done
	VALID_COLUMN_FIELDS="$VALID_FIELDS
$VALID_COLUMN_FIELDS"
done

CACHE=','
FOUND=0
FIELDCOUNT=`echo "$FIELDS" | wc -l`
RESULTS=''
I=0
while [ $FOUND -lt $FIELDCOUNT ]; do
	IFS='
'
	N=$FIELDCOUNT
	for VALID_FIELDS in $VALID_COLUMN_FIELDS; do
		if [ "`echo "$VALID_FIELDS" | tr -cd ',' | wc -c`" -eq $I ]; then
			IFS=','
			for FIELD in $VALID_FIELDS; do
				case "$CACHE" in
					*,$FIELD,*) continue ;;
				esac
				CACHE="$CACHE$FIELD,"
				RESULTS="$N,$FIELD
$RESULTS"
			done
			FOUND=$(( FOUND + 1 ))
		fi
		N=$(( N - 1 ))
	done
	I=$(( I + 1 ))
done

COLUMNS=`echo "$RESULTS" | grep ',[0-6]$' | cut -d, -f1 | paste -sd,`
ANSWER2=$(( `echo "$TICKET" | cut -d, -f"$COLUMNS" --output-delimiter='*'` ))

echo '--- Day 16: Ticket Translation ---'
echo " Answer 1: $ANSWER1"
echo " Answer 2: $ANSWER2"
