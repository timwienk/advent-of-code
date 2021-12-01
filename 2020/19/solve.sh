#!/bin/sh
set -efuC

DIR=`readlink -m \`dirname $0\``
if [ $# -gt 0 ]; then
	FILE="$DIR/$1"
else
	FILE="$DIR/input"
fi

START=''
RULES=''
INPUT=''

get_rule(){
	echo "$RULES" | sed --posix -n "$(( $1 + 1 )){p;q;}"
}

set_rule(){
	RULES=`echo "$RULES" | sed --posix "$(( $1 + 1 ))s/.*/$2/"`
}

parse_rule(){
	echo -n '.' >&2

	RECURSE=''
	WRAP=''
	PARSED=''
	for PART in `get_rule $1`; do
		case "$PART" in
			[ab]*) PARSED="$PARSED$PART" ;;
			\|) PARSED="$PARSED$PART"; WRAP=1 ;;
			$1) PARSED="$PARSED$1"; RECURSE=1 ;;
			[0-9]*) PARSED="$PARSED`parse_rule $PART`" ;;
		esac
	done
	if [ -n "$WRAP" ]; then
		PARSED="($PARSED)"
	fi

	if [ -n "$RECURSE" ]; then
		I=0
		while [ $I -lt 4 ]; do
			echo -n '*' >&2
			PARSED=`echo "$PARSED" | sed "s/$1/$PARSED/"`
			I=$(( I + 1 ))
		done
	fi

	#set_rule $1 "$PARSED"
	echo "$PARSED"
}

while read LINE; do
	case "$LINE" in
		[0-9]*)
			if [ -z "$RULES" ]; then
				RULES="$LINE"
			else
				RULES="$RULES
$LINE"
			fi
			;;
		[ab]*)
			if [ -z "$INPUT" ]; then
				INPUT="$LINE"
			else
				INPUT="$INPUT
$LINE"
			fi
	esac
done < "$FILE"
RULES=`echo "$RULES" | sort -n | cut -d' ' -f2- | tr -d '"'`

ANSWER1=''
ANSWER2=''

echo -n '[1]' >&2
RULE=`parse_rule 0`
ANSWER1=`echo "$INPUT" | grep -E "^$RULE$" | wc -l`
echo >&2

echo -n '[2]' >&2
set_rule 8 '42 | 42 8'
set_rule 11 '42 31 | 42 11 31'
RULE=`parse_rule 0`
ANSWER2=`echo "$INPUT" | grep -E "^$RULE$" | wc -l`
echo >&2

echo '--- Day 19: Monster Messages ---'
echo " Answer 1: $ANSWER1"
echo " Answer 2: $ANSWER2"
