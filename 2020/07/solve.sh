#!/bin/sh
set -efuC

DIR=`readlink -m \`dirname $0\``
if [ $# -gt 0 ]; then
	FILE="$DIR/$1"
else
	FILE="$DIR/input"
fi

INPUT=`grep '[0-9]' "$FILE" | sed -E -e 's/^([a-z]+) ([a-z]+) bags contain/\1_\2/' -e 's/([0-9]) ([a-z]+) ([a-z]+) bags?[,.]/\2_\3:\1/g'`
EOL='
'

get_parent_bags(){
	PARENTS=''

	IFS=$EOL
	for LINE in $INPUT; do
		case "$LINE" in
			*$1:*)
				IFS=' '
				for PARENT in $LINE; do
					if [ -z "$PARENTS" ]; then
						PARENTS=$PARENT
					else
						PARENTS=$PARENTS$EOL$PARENT
					fi
					PARENT_PARENTS=`get_parent_bags "$PARENT"`
					if [ -n "$PARENT_PARENTS" ]; then
						PARENTS="$PARENTS$EOL$PARENT_PARENTS"
					fi
					break
				done
				;;
		esac
	done

	echo $PARENTS | sort -u
}
count_child_bags(){
	COUNT=0

	IFS=$EOL
	for LINE in $INPUT; do
		case "$LINE" in
			$1*)
				IFS=' '
				for CHILDREN in $LINE; do
					if [ "$CHILDREN" != "$1" ]; then
						IFS=':'
						for PART in $CHILDREN; do
							case $PART in
								[0-9]) CHILD_COUNT=$PART;;
								*) CHILD_NAME=$PART;;
							esac
						done

						COUNT=$(( COUNT + CHILD_COUNT + CHILD_COUNT * `count_child_bags "$CHILD_NAME"` ))
					fi
				done
				break
				;;
		esac
	done

	echo $COUNT
}

ANSWER1=`get_parent_bags shiny_gold | wc -l`
ANSWER2=`count_child_bags shiny_gold`

echo '--- Day 7: Handy Haversacks ---'
echo " Answer 1: $ANSWER1"
echo " Answer 2: $ANSWER2"
