#!/bin/sh
set -efuC

DIR=`readlink -m \`dirname $0\``
if [ $# -gt 0 ]; then
	FILE="$DIR/$1"
else
	FILE="$DIR/input"
fi

INPUT1=''
INPUT2=''
CACHE=''

ANSWER1=''
ANSWER2=''

FIND2=''
while read LINE; do
	case "$LINE" in
		Player\ 1:) ;;
		Player\ 2:) FIND2=1 ;;
		[0-9]*)
			if [ -z "$FIND2" ]; then
				if [ -z "$INPUT1" ]; then
					INPUT1="$LINE"
				else
					INPUT1="$INPUT1	$LINE"
				fi
			else
				if [ -z "$INPUT2" ]; then
					INPUT2="$LINE"
				else
					INPUT2="$INPUT2	$LINE"
				fi
			fi
			;;
	esac
done < "$FILE"

play_normal_round(){
	local CARD1="`echo "	$1" | cut -f2`"
	local CARD2="`echo "	$2" | cut -f2`"
	local CARDS1="`echo "	$1" | cut -f3-`"
	local CARDS2="`echo "	$2" | cut -f3-`"

	if [ $CARD1 -gt $CARD2 ]; then
		if [ -n "$CARDS1" ]; then
			echo "1,$CARDS1	$CARD1	$CARD2,$CARDS2"
		else
			echo "1,$CARD1	$CARD2,$CARDS2"
		fi
	elif [ $CARD1 -lt $CARD2 ]; then
		if [ -n "$CARDS2" ]; then
			echo "2,$CARDS1,$CARDS2	$CARD2	$CARD1"
		else
			echo "2,$CARDS1,$CARD2	$CARD1"
		fi
	fi

	echo -n '.' >&2
}

play_normal_game(){
	local CARDS1="$1"
	local CARDS2="$2"
	local CACHE=''

	echo -n '[N]' >&2

	while [ -n "$CARDS1" -a -n "$CARDS2" ]; do
		if echo -n "$CACHE" | grep -q "^$CARDS1,$CARDS2$"; then
			local CARDS2=''
		else
			local CACHE="$CARDS1,$CARDS2
$CACHE"

			local RESULT="`play_normal_round "$CARDS1" "$CARDS2"`"
			local CARDS1="`echo "$RESULT" | cut -d, -f2`"
			local CARDS2="`echo "$RESULT" | cut -d, -f3`"
		fi
	done

	echo >&2

	if [ -n "$CARDS1" ]; then
		echo "1,$CARDS1"
	else
		echo "2,$CARDS2"
	fi
}

play_recursive_game(){
	local CARDS1="$1"
	local CARDS2="$2"
	local COUNT1="`echo "	$CARDS1" | tr -cd '\t' | wc -c`"
	local COUNT2="`echo "	$CARDS2" | tr -cd '\t' | wc -c`"
	local CACHE=''

	local GAME=0
	if [ $# -gt 2 ]; then
		local PREFIX="$3"
	else
		local PREFIX='R1'
	fi

	echo -n "[$PREFIX]" >&2

	while [ -n "$CARDS1" -a -n "$CARDS2" ]; do
		if echo -n "$CACHE" | grep -q "^$CARDS1,$CARDS2$"; then
			local CARDS2=''
			break
		else
			local CACHE="$CARDS1,$CARDS2
$CACHE"

			local CARD1=`echo "	$CARDS1" | cut -f2`
			local CARD2=`echo "	$CARDS2" | cut -f2`

			if [ $COUNT1 -gt $CARD1 -a $COUNT2 -gt $CARD2 ]; then
				local CARDS1="`echo "	$CARDS1" | cut -f3-`"
				local CARDS2="`echo "	$CARDS2" | cut -f3-`"
				local GAME=$(( GAME + 1 ))
				echo >&2
				local RECURSIVE_CARDS1="`echo "	$CARDS1" | cut -f2-$(( CARD1 + 1 ))`"
				local RECURSIVE_CARDS2="`echo "	$CARDS2" | cut -f2-$(( CARD2 + 1 ))`"
				local RESULT="`play_recursive_game "$RECURSIVE_CARDS1" "$RECURSIVE_CARDS2" "$PREFIX.$GAME"`"
				echo -n "[$PREFIX]" >&2
				local WINNER="`echo "$RESULT" | cut -d, -f1`"
				case "$WINNER" in
					1) local CARDS1="$CARDS1	$CARD1	$CARD2" ;;
					2) local CARDS2="$CARDS2	$CARD2	$CARD1" ;;
				esac
			else
				local RESULT="`play_normal_round "$CARDS1" "$CARDS2"`"
				local WINNER="`echo "$RESULT" | cut -d, -f1`"
				local CARDS1="`echo "$RESULT" | cut -d, -f2`"
				local CARDS2="`echo "$RESULT" | cut -d, -f3`"
			fi

			case "$WINNER" in
				1)
					local COUNT1=$(( COUNT1 + 1 ))
					local COUNT2=$(( COUNT2 - 1 ))
					;;
				2)
					local COUNT1=$(( COUNT1 - 1 ))
					local COUNT2=$(( COUNT2 + 1 ))
					;;
			esac
		fi
	done

	echo >&2

	if [ -n "$CARDS1" ]; then
		echo "1,$CARDS1"
	else
		echo "2,$CARDS2"
	fi
}

GAME1_CARDS=`play_normal_game "$INPUT1" "$INPUT2" | cut -d, -f2`
GAME1_COUNT=`echo "	$GAME1_CARDS" | tr -cd '\t' | wc -c`

ANSWER1=0
for CARD in $GAME1_CARDS; do
	ANSWER1=$(( ANSWER1 + CARD * GAME1_COUNT ))
	GAME1_COUNT=$(( GAME1_COUNT - 1 ))
done

GAME2_CARDS=`play_recursive_game "$INPUT1" "$INPUT2" | cut -d, -f2`
GAME2_COUNT=`echo "	$GAME2_CARDS" | tr -cd '\t' | wc -c`

ANSWER2=0
for CARD in $GAME2_CARDS; do
	ANSWER2=$(( ANSWER2 + CARD * GAME2_COUNT ))
	GAME2_COUNT=$(( GAME2_COUNT - 1 ))
done

echo '--- Day 22: Crab Combat ---'
echo " Answer 1: $ANSWER1"
echo " Answer 2: $ANSWER2"
