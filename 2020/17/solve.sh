#!/bin/sh
set -efuC

DIR=`readlink -m \`dirname $0\``
if [ $# -gt 0 ]; then
	FILE="$DIR/$1"
else
	FILE="$DIR/input"
fi

get_min(){
	echo $(( `sort -n | head -n1` - 2 ))
}
get_max(){
	echo $(( `sort -rn | head -n1` + 2 ))
}

INPUT=''
Y=0
while read LINE; do
	X=0
	for STATUS in `echo $LINE | fold -w1`; do
		if [ "$STATUS" = '#' ]; then
			INPUT="$X,$Y,0,0
$INPUT"
		fi
		X=$(( X + 1 ))
	done
	Y=$(( Y + 1 ))
done < "$FILE"

INPUT1="$INPUT"
I=0
while [ $I -lt 6 ]; do
	echo -n "[1] Round $I" >&2

	OUTPUT1=''

	MIN_X=`echo -n "$INPUT1" | cut -d, -f1 | get_min`
	MIN_Y=`echo -n "$INPUT1" | cut -d, -f2 | get_min`
	MIN_Z=`echo -n "$INPUT1" | cut -d, -f3 | get_min`
	MAX_X=`echo -n "$INPUT1" | cut -d, -f1 | get_max`
	MAX_Y=`echo -n "$INPUT1" | cut -d, -f2 | get_max`
	MAX_Z=`echo -n "$INPUT1" | cut -d, -f3 | get_max`

	X=$MIN_X
	while [ $X -le $MAX_X ]; do
		Y=$MIN_Y
		while [ $Y -le $MAX_Y ]; do
			echo -n '.' >&2
			Z=$MIN_Z
			while [ $Z -le $MAX_Z ]; do
				ACTIVE=''
				for LINE in $INPUT1; do
					if [ "$LINE" = "$X,$Y,$Z,0" ]; then
						ACTIVE=1
						break
					fi
				done

				ACTIVE_NEIGHBOURS=0
				for MOD_X in -1 0 1; do
					for MOD_Y in -1 0 1; do
						for MOD_Z in -1 0 1; do
							if [ "$MOD_X$MOD_Y$MOD_Z" != '000' ]; then
								for LINE in $INPUT1; do
									if [ "$LINE" = "$(( X + MOD_X )),$(( Y + MOD_Y )),$(( Z + MOD_Z )),0" ]; then
										ACTIVE_NEIGHBOURS=$(( ACTIVE_NEIGHBOURS + 1 ))
										break
									fi
								done
							fi
						done
					done
				done

				if [ -n "$ACTIVE" ]; then
					if [ $ACTIVE_NEIGHBOURS -ne 2 -a $ACTIVE_NEIGHBOURS -ne 3 ]; then
						ACTIVE=''
					fi
				else
					if [ $ACTIVE_NEIGHBOURS -eq 3 ]; then
						ACTIVE=1
					fi
				fi

				if [ -n "$ACTIVE" ]; then
					OUTPUT1="$X,$Y,$Z,0
$OUTPUT1"
				fi

				Z=$(( Z + 1 ))
			done
			Y=$(( Y + 1 ))
		done
		X=$(( X + 1 ))
	done

	INPUT1="$OUTPUT1"
	I=$(( I + 1 ))
	echo >&2
done

INPUT2="$INPUT"
I=0
while [ $I -lt 6 ]; do
	echo -n "[2] Round $I" >&2
	OUTPUT2=''

	MIN_X=`echo -n "$INPUT2" | cut -d, -f1 | get_min`
	MIN_Y=`echo -n "$INPUT2" | cut -d, -f2 | get_min`
	MIN_Z=`echo -n "$INPUT2" | cut -d, -f3 | get_min`
	MIN_W=`echo -n "$INPUT2" | cut -d, -f3 | get_min`
	MAX_X=`echo -n "$INPUT2" | cut -d, -f1 | get_max`
	MAX_Y=`echo -n "$INPUT2" | cut -d, -f2 | get_max`
	MAX_Z=`echo -n "$INPUT2" | cut -d, -f3 | get_max`
	MAX_W=`echo -n "$INPUT2" | cut -d, -f3 | get_max`

	X=$MIN_X
	while [ $X -le $MAX_X ]; do
		Y=$MIN_Y
		while [ $Y -le $MAX_Y ]; do
			echo -n '.' >&2
			Z=$MIN_Z
			while [ $Z -le $MAX_Z ]; do
				W=$MIN_W
				while [ $W -le $MAX_W ]; do
					ACTIVE=''
					for LINE in $INPUT2; do
						if [ "$LINE" = "$X,$Y,$Z,$W" ]; then
							ACTIVE=1
							break
						fi
					done

					ACTIVE_NEIGHBOURS=0
					for MOD_X in -1 0 1; do
						for MOD_Y in -1 0 1; do
							for MOD_Z in -1 0 1; do
								for MOD_W in -1 0 1; do
									if [ "$MOD_X$MOD_Y$MOD_Z$MOD_W" != '0000' ]; then
										for LINE in $INPUT2; do
											if [ "$LINE" = "$(( X + MOD_X )),$(( Y + MOD_Y )),$(( Z + MOD_Z )),$(( W + MOD_W ))" ]; then
												ACTIVE_NEIGHBOURS=$(( ACTIVE_NEIGHBOURS + 1 ))
												break
											fi
										done
									fi
								done
							done
						done
					done

					if [ -n "$ACTIVE" ]; then
						if [ $ACTIVE_NEIGHBOURS -ne 2 -a $ACTIVE_NEIGHBOURS -ne 3 ]; then
							ACTIVE=''
						fi
					else
						if [ $ACTIVE_NEIGHBOURS -eq 3 ]; then
							ACTIVE=1
						fi
					fi

					if [ -n "$ACTIVE" ]; then
						OUTPUT2="$X,$Y,$Z,$W
	$OUTPUT2"
					fi

					W=$(( W + 1 ))
				done
				Z=$(( Z + 1 ))
			done
			Y=$(( Y + 1 ))
		done
		X=$(( X + 1 ))
	done

	INPUT2="$OUTPUT2"
	I=$(( I + 1 ))
	echo >&2
done

ANSWER1=`echo -n "$INPUT1" | wc -l`
ANSWER2=`echo -n "$INPUT2" | wc -l`

echo '--- Day 17: Conway Cubes ---'
echo " Answer 1: $ANSWER1"
echo " Answer 2: $ANSWER2"
