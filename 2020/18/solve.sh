#!/bin/sh
set -efuC

DIR=`readlink -m \`dirname $0\``
if [ $# -gt 0 ]; then
	FILE="$DIR/$1"
else
	FILE="$DIR/input"
fi

INPUT=`sed --posix -e 's/(/( /g' -e 's/)/ )/g' "$FILE"`

run1(){
	VALUE=0

	OPERATOR=''
	while [ $# -gt 0 ]; do
		CHAR=$1
		shift

		case "$CHAR" in
			\*|+)
				OPERATOR=$CHAR
				;;
			\()
				CHARS=''
				NESTED=1
				while [ $NESTED -gt 0 ]; do
					case "$1" in
						\()
							NESTED=$(( NESTED + 1 ))
							CHARS="$CHARS $1"
							;;
						\))
							NESTED=$(( NESTED - 1 ))
							if [ $NESTED -gt 0 ]; then
								CHARS="$CHARS $1"
							fi
							;;
						*)
							CHARS="$CHARS $1"
							;;
					esac
					shift
				done

				if [ -z "$OPERATOR" ]; then
					VALUE=`run1 $CHARS`
				elif [ "$OPERATOR" = '+' ]; then
					VALUE=$(( VALUE + `run1 $CHARS` ))
				else
					VALUE=$(( VALUE * `run1 $CHARS` ))
				fi
				;;
			[0-9])
				if [ -z "$OPERATOR" ]; then
					VALUE=$CHAR
				elif [ "$OPERATOR" = '+' ]; then
					VALUE=$(( VALUE + CHAR ))
				else
					VALUE=$(( VALUE * CHAR ))
				fi
				;;
		esac
	done

	echo $VALUE
}

run2(){
	VALUE=0

	OPERATOR=''
	while [ $# -gt 0 ]; do
		CHAR=$1
		shift

		case "$CHAR" in
			\*|+)
				OPERATOR=$CHAR
				;;
			\()
				if [ "$OPERATOR" = '*' ]; then
					VALUE=$(( VALUE * `run2 $CHAR $@` ))
					shift $#
				else
					CHARS=''
					NESTED=1
					while [ $NESTED -gt 0 ]; do
						case "$1" in
							\()
								NESTED=$(( NESTED + 1 ))
								CHARS="$CHARS $1"
								;;
							\))
								NESTED=$(( NESTED - 1 ))
								if [ $NESTED -gt 0 ]; then
									CHARS="$CHARS $1"
								fi
								;;
							*)
								CHARS="$CHARS $1"
								;;
						esac
						shift
					done

					if [ -z "$OPERATOR" ]; then
						VALUE=`run2 $CHARS`
					else
						VALUE=$(( VALUE + `run2 $CHARS` ))
					fi
				fi
				;;
			[0-9])
				if [ -z "$OPERATOR" ]; then
					VALUE=$CHAR
				elif [ "$OPERATOR" = '+' ]; then
					VALUE=$(( VALUE + CHAR ))
				else
					VALUE=$(( VALUE * `run2 $CHAR $@` ))
					shift $#
				fi
				;;
		esac
	done

	echo $VALUE
}

ANSWER1=0
ANSWER2=0

IFS='
'
for LINE in $INPUT; do
	IFS=' '
	VALUE1=`run1 $LINE`
	VALUE2=`run2 $LINE`
	ANSWER1=$(( ANSWER1 + VALUE1 ))
	ANSWER2=$(( ANSWER2 + VALUE2 ))
done

echo '--- Day 18: Operation Order ---'
echo " Answer 1: $ANSWER1"
echo " Answer 2: $ANSWER2"
