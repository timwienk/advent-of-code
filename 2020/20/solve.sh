#!/bin/sh
set -efuC

DIR=`readlink -m \`dirname $0\``
if [ $# -gt 0 ]; then
	FILE="$DIR/$1"
else
	FILE="$DIR/input"
fi

process_tile(){
	TOP=''
	BOTTOM=''
	LEFT=''
	RIGHT=''
	CONTENT=''

	while [ $# -gt 0 ]; do
		if [ -z "$TOP" ]; then
			TOP="$1"
		fi
		if [ -n "$CONTENT" ]; then
			CONTENT="$CONTENT,"
		fi
		I=0
		for CHAR in `echo "$1" | fold -w1`; do
			I=$(( I + 1 ))
			case $I in
				1) LEFT="$LEFT$CHAR" ;;
				10) RIGHT="$RIGHT$CHAR" ;;
				*) CONTENT="$CONTENT$CHAR" ;;
			esac
		done
		BOTTOM="$1"
		shift
	done

	echo "$TOP $RIGHT $BOTTOM $LEFT `echo "$LEFT $BOTTOM $RIGHT $TOP" | rev` $CONTENT"
}

TILES=''

TILE_NUMBER=''
TILE_CONTENT=''
while read LINE; do
	case "$LINE" in
		Tile*)
			if [ -n "$TILE_NUMBER" ]; then
				TILES="$TILE_NUMBER `process_tile $TILE_CONTENT`
$TILES"
			fi
			TILE_NUMBER=`echo "$LINE" | tr -cd '0-9'`
			TILE_CONTENT=''
			;;
		*)
			if [ -z "$TILE_CONTENT" ]; then
				TILE_CONTENT="$LINE"
			else
				TILE_CONTENT="$TILE_CONTENT $LINE"
			fi
			;;
	esac
done < "$FILE"
TILES="$TILE_NUMBER `process_tile $TILE_CONTENT`
$TILES"

IMAGE_TILES=''
MUTATIONS=''

ANSWER1=1

IFS='
'
for TILE in $TILES; do
	IFS='
'
	TILE_NUMBER=0
	MATCHES=0
	for CANDIDATE in $TILES; do
		IFS=' '
		TILE_INDEX=0
		for TILE_PART in $TILE; do
			CANDIDATE_INDEX=0
			case $TILE_PART in
				*,*) ;;
				[0-9]*)
					TILE_NUMBER=$TILE_PART
					if [ -z "$IMAGE_TILES" ]; then
						IMAGES_TILES="$TILE_NUMBER"
						TILE_MUTATION=`echo -n "$MUTATIONS" | grep "^$TILE_NUMBER" | cut -f2-`
					fi
					;;
				*)
					if [ $TILE_INDEX -gt 3 ]; then
						break
					fi
					TILE_INDEX=$(( TILE_INDEX + 1 ))
					for CANDIDATE_PART in $CANDIDATE; do
						case $CANDIDATE_PART in
							*,*) ;;
							[0-9]*)
								if [ "$TILE_NUMBER" = "$CANDIDATE_PART" ]; then
									break
								fi
								CANDIDATE_NUMBER=$CANDIDATE_PART
								;;
							*)
								CANDIDATE_INDEX=$(( CANDIDATE_INDEX + 1 ))
								if [ "$TILE_PART" = "$CANDIDATE_PART" ]; then
									case $TILE_INDEX in
										1)
											case $CANDIDATE_INDEX in
												1) CANDIDATE_MUTATION='H0 V1 R0';;
												2) CANDIDATE_MUTATION='H1 V0 R3';;
												3) CANDIDATE_MUTATION='H0 V0 R0';;
												4) CANDIDATE_MUTATION='H0 V0 R3';;
												5) CANDIDATE_MUTATION='H0 V0 R2';;
												6) CANDIDATE_MUTATION='H0 V0 R1';;
												7) CANDIDATE_MUTATION='H0 V1 R2';;
												8) CANDIDATE_MUTATION='H1 V0 R1';;
											esac
											;;
										2)
											case $CANDIDATE_INDEX in
												1) CANDIDATE_MUTATION='H0 V1 R1';;
												2) CANDIDATE_MUTATION='H1 V0 R0';;
												3) CANDIDATE_MUTATION='H0 V0 R1';;
												4) CANDIDATE_MUTATION='H0 V0 R0';;
												5) CANDIDATE_MUTATION='H0 V0 R3';;
												6) CANDIDATE_MUTATION='H0 V0 R2';;
												7) CANDIDATE_MUTATION='H0 V1 R3';;
												8) CANDIDATE_MUTATION='H1 V0 R2';;
											esac
											;;
										3)
											case $CANDIDATE_INDEX in
												1) CANDIDATE_MUTATION='H0 V0 R0';;
												2) CANDIDATE_MUTATION='H0 V0 R3';;
												3) CANDIDATE_MUTATION='H0 V1 R0';;
												4) CANDIDATE_MUTATION='H1 V0 R3';;
												5) CANDIDATE_MUTATION='H0 V1 R2';;
												6) CANDIDATE_MUTATION='H1 V0 R1';;
												7) CANDIDATE_MUTATION='H0 V0 R2';;
												8) CANDIDATE_MUTATION='H0 V0 R1';;
											esac
											;;
										4)
											case $CANDIDATE_INDEX in
												1) CANDIDATE_MUTATION='H0 V0 R1';;
												2) CANDIDATE_MUTATION='H0 V0 R0';;
												3) CANDIDATE_MUTATION='H0 V1 R1';;
												4) CANDIDATE_MUTATION='H1 V0 R0';;
												5) CANDIDATE_MUTATION='H0 V1 R3';;
												6) CANDIDATE_MUTATION='H1 V0 R2';;
												7) CANDIDATE_MUTATION='H0 V0 R3';;
												8) CANDIDATE_MUTATION='H0 V0 R2';;
											esac
											;;
									esac
									echo "$TILE_NUMBER ($TILE_INDEX) --$CANDIDATE_MUTATION--> $CANDIDATE_NUMBER ($CANDIDATE_INDEX)"
									MATCHES=$(( MATCHES + 1 ))
									break 2
								fi
								;;
						esac
					done
					;;
			esac
		done
	done
	if [ $MATCHES -eq 2 ]; then
		echo "Found corner: $TILE_NUMBER"
		ANSWER1=$(( ANSWER1 * TILE_NUMBER ))
	fi
done

ANSWER2=''

echo '--- Day 20: Jurassic Jigsaw ---'
echo " Answer 1: $ANSWER1"
echo " Answer 2: $ANSWER2"
