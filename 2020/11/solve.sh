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

get_seat_status(){
	X=$1
	Y=$2
	# This should at the very least use temporary files, if I remain stubborn
	# enough to not use non-POSIX features like arrays.
	echo "$INPUT" | dd status=none ibs=1 count=1 skip=$(( (X - 1) + (Y - 1) + (Y - 1) * MAX_X))
}

get_new_empty_seat_status(){
	X=$1
	Y=$2
	OCCUPIED_THRESHOLD=$3
	CHECK_SIGHT=''
	if [ $# -gt 3 ]; then
		CHECK_SIGHT=1
	fi

	STATUS='#'
	OCCUPIED=0
	for MOD_Y in -1 0 1; do
		CHECK_Y=$(( Y + MOD_Y ))
		if [ $CHECK_Y -gt 0 -a $CHECK_Y -le $MAX_Y ]; then
			for MOD_X in -1 0 1; do
				CHECK_X=$(( X + MOD_X ))
				if [ "$MOD_X$MOD_Y" != '00' -a $CHECK_X -gt 0 -a $CHECK_X -le $MAX_X ]; then
					ADJECENT_STATUS=`get_seat_status $CHECK_X $CHECK_Y`
					if [ -n "$CHECK_SIGHT" ]; then
						while [ $ADJECENT_STATUS = '.' ]; do
							CHECK_Y=$(( CHECK_Y + MOD_Y ))
							CHECK_X=$(( CHECK_X + MOD_X ))
							if [ $CHECK_Y -gt 0 -a $CHECK_Y -le $MAX_Y -a $CHECK_X -gt 0 -a $CHECK_X -le $MAX_X ]; then
								ADJECENT_STATUS=`get_seat_status $CHECK_X $CHECK_Y`
							else
								break
							fi
						done
						CHECK_Y=$(( Y + MOD_Y ))
						CHECK_X=$(( X + MOD_X ))
					fi
					if [ $ADJECENT_STATUS = '#' ]; then
						OCCUPIED=$(( OCCUPIED + 1 ))
						if [ $OCCUPIED -ge $OCCUPIED_THRESHOLD ]; then
							STATUS='L'
							break 2
						fi
					fi
				fi
			done
		fi
	done
	echo $STATUS
}

get_new_occupied_seat_status(){
	X=$1
	Y=$2
	OCCUPIED_THRESHOLD=$3
	CHECK_SIGHT=''
	if [ $# -gt 3 ]; then
		CHECK_SIGHT=1
	fi

	STATUS='#'
	OCCUPIED=0
	for MOD_Y in -1 0 1; do
		CHECK_Y=$(( Y + MOD_Y ))
		if [ $CHECK_Y -gt 0 -a $CHECK_Y -le $MAX_Y ]; then
			for MOD_X in -1 0 1; do
				CHECK_X=$(( X + MOD_X ))
				if [ "$MOD_X$MOD_Y" != '00' -a $CHECK_X -gt 0 -a $CHECK_X -le $MAX_X ]; then
					ADJECENT_STATUS=`get_seat_status $CHECK_X $CHECK_Y`
					if [ -n "$CHECK_SIGHT" ]; then
						while [ $ADJECENT_STATUS = '.' ]; do
							CHECK_Y=$(( CHECK_Y + MOD_Y ))
							CHECK_X=$(( CHECK_X + MOD_X ))
							if [ $CHECK_Y -gt 0 -a $CHECK_Y -le $MAX_Y -a $CHECK_X -gt 0 -a $CHECK_X -le $MAX_X ]; then
								ADJECENT_STATUS=`get_seat_status $CHECK_X $CHECK_Y`
							else
								break
							fi
						done
						CHECK_Y=$(( Y + MOD_Y ))
						CHECK_X=$(( X + MOD_X ))
					fi
					if [ $ADJECENT_STATUS = '#' ]; then
						OCCUPIED=$(( OCCUPIED + 1 ))
						if [ $OCCUPIED -ge $OCCUPIED_THRESHOLD ]; then
							STATUS='L'
							break 2
						fi
					fi
				fi
			done
		fi
	done
	echo $STATUS
}

I=0
INPUT="`cat $FILE`"
OUTPUT1=''
while [ "$INPUT" != "$OUTPUT1" ]; do
	echo -n "[1] Round $I" >&2
	X=0
	Y=0

	if [ -n "$OUTPUT1" ]; then
		INPUT="$OUTPUT1"
	fi
	OUTPUT1=''

	while [ $Y -lt $MAX_Y ]; do
		echo -n '.' >&2
		X=0
		Y=$(( Y + 1 ))
		while [ $X -lt $MAX_X ]; do
			X=$(( X + 1 ))
			case `get_seat_status $X $Y` in
				.) SEAT='.';;
				L) SEAT=`get_new_empty_seat_status $X $Y 1`;;
				\#) SEAT=`get_new_occupied_seat_status $X $Y 4`;;
			esac
			OUTPUT1="$OUTPUT1$SEAT"
		done
		OUTPUT1="$OUTPUT1
"
	done

	I=$(( I + 1 ))
	echo >&2
done

I=0
INPUT="`cat $FILE`"
OUTPUT2=''
while [ "$INPUT" != "$OUTPUT2" ]; do
	echo -n "[2] Round $I" >&2
	X=0
	Y=0

	if [ -n "$OUTPUT2" ]; then
		INPUT="$OUTPUT2"
	fi
	OUTPUT2=''

	while [ $Y -lt $MAX_Y ]; do
		echo -n '.' >&2
		X=0
		Y=$(( Y + 1 ))
		while [ $X -lt $MAX_X ]; do
			X=$(( X + 1 ))
			case `get_seat_status $X $Y` in
				.) SEAT='.';;
				L) SEAT=`get_new_empty_seat_status $X $Y 1 1`;;
				\#) SEAT=`get_new_occupied_seat_status $X $Y 5 1`;;
			esac
			OUTPUT2="$OUTPUT2$SEAT"
		done
		OUTPUT2="$OUTPUT2
"
	done

	I=$(( I + 1 ))
	echo >&2
done

ANSWER1=`echo "$OUTPUT1" | tr -cd '#' | wc -c`
ANSWER2=`echo "$OUTPUT2" | tr -cd '#' | wc -c`

echo '--- Day 11: Seating System ---'
echo " Answer 1: $ANSWER1"
echo " Answer 2: $ANSWER2"
