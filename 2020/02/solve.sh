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

check_char_count(){
	COUNT=`echo -n "$4" | tr -cd "$3" | wc -c`
	if [ $COUNT -lt $1 -o $COUNT -gt $2 ]; then
		return 1
	fi
}
check_char_positions(){
	case "`echo -n "$4" | cut -b$1,$2`" in
		$3$3) return 1;;
		?$3|$3?) return 0;;
		*) return 1;;
	esac
}

while read LINE; do
	IFS=' -:'
	if check_char_count $LINE; then
		ANSWER1=$(( $ANSWER1 + 1 ))
	fi
	if check_char_positions $LINE; then
		ANSWER2=$(( $ANSWER2 + 1 ))
	fi
done < "$FILE"

echo '--- Day 2: Password Philosophy ---'
echo " Answer 1: $ANSWER1"
echo " Answer 2: $ANSWER2"
