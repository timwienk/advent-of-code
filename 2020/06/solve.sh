#!/bin/sh
set -efuC

DIR=`readlink -m \`dirname $0\``
if [ $# -gt 0 ]; then
	FILE="$DIR/$1"
else
	FILE="$DIR/input"
fi

ANSWER1=0
ANSWER2=0

count_common_answers(){
	UNIQUE_ANSWERS=$1
	shift

	COUNT=0

	for C in $UNIQUE_ANSWERS; do
		IFS=' '
		COMMON=1
		for DATA in $@; do
			case "$DATA" in
				*$C*) ;;
				*) COMMON=''; break;;
			esac
		done
		if [ -n "$COMMON" ]; then
			COUNT=$(( COUNT + 1 ))
		fi
	done

	echo $COUNT
}

IFS='
'
for LINE in `tr "\n" ' ' < "$FILE" | sed -E 's/ ( |$)/\n/g'`; do
	UNIQUE_ANSWERS=`echo "$LINE" | tr -d ' ' | fold -w1 | sort -u`

	ANSWER1=$(( ANSWER1 + `echo "$UNIQUE_ANSWERS" | wc -l` ))
	ANSWER2=$(( ANSWER2 + `count_common_answers "$UNIQUE_ANSWERS" $LINE` ))
done

echo '--- Day 6: Custom Customs ---'
echo " Answer 1: $ANSWER1"
echo " Answer 2: $ANSWER2"
