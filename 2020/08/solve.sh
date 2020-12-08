#!/bin/sh
set -fuC

DIR=`readlink -m \`dirname $0\``
if [ $# -gt 0 ]; then
	FILE="$DIR/$1"
else
	FILE="$DIR/input"
fi

run(){
	STATUS=0
	VALUE=0
	STACK='.'

	FIX_LINE=0
	NEW_OPCODE=''
	if [ $# -ge 2 ]; then
		FIX_LINE="$1"
		NEW_OPCODE="$2"
	fi

	NEXT=1
	while true; do
		INSTRUCTION=`sed -n "${NEXT}{p;q;}" "$FILE"`

		if [ -n "$INSTRUCTION" ]; then
			STACK="$STACK$NEXT."

			for PART in $INSTRUCTION; do
				case $PART in
					[a-z][a-z][a-z]) OPCODE=$PART;;
					-*|+*) ARGUMENT=$PART;;
				esac
			done

			if [ $FIX_LINE -eq $NEXT ]; then
				OPCODE=$NEW_OPCODE
			fi

			case $OPCODE in
				nop) NEXT=$(( $NEXT + 1 ));;
				acc) NEXT=$(( $NEXT + 1 )); VALUE=$(( VALUE + ARGUMENT ));;
				jmp) NEXT=$(( $NEXT + ARGUMENT ));;
			esac

			case "$STACK" in
				*.$NEXT.*) STATUS=1; break;;
			esac
		else
			break
		fi
	done

	echo $VALUE
	return $STATUS
}

ANSWER1=`run`
ANSWER2=''

N=0
while read LINE; do
	N=$(( N + 1 ))
	STATUS=255
	case "$LINE" in
		nop*) ANSWER2=`run $N jmp`; STATUS=$?;;
		jmp*) ANSWER2=`run $N nop`; STATUS=$?;;
	esac
	if [ $STATUS -lt 255 ]; then
		printf '%3d\t%-8s\t%4d\n' "$N" "$LINE" "$ANSWER2" >&2
	fi
	if [ $STATUS -eq 0 ]; then
		break
	fi
done < "$FILE"

echo '--- Day 8: Handheld Halting ---'
echo " Answer 1: $ANSWER1"
echo " Answer 2: $ANSWER2"
