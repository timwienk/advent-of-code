#!/bin/sh
set -efuC

DIR=`readlink -m \`dirname $0\``
if [ $# -gt 0 ]; then
	FILE="$DIR/$1"
else
	FILE="$DIR/input"
fi

INPUT=`tr -d '(),' < "$FILE" | tr -cd 'a-z \n'`

ALLERGENS=''
INGREDIENTS=''

IFS='
'
for LINE in $INPUT; do
	LINE_INGREDIENTS=''
	LINE_ALLERGENS=''

	FIND_ALLERGENS=''
	IFS=' '
	for WORD in $LINE; do
		case $WORD in
			contains)
				FIND_ALLERGENS=1
				;;
			*)
				if [ -z "$FIND_ALLERGENS" ]; then
					LINE_INGREDIENTS="$LINE_INGREDIENTS $WORD"
					case "$INGREDIENTS" in
						*$WORD*) ;;
						*) INGREDIENTS="$INGREDIENTS $WORD" ;;
					esac
				else
					LINE_ALLERGENS="$LINE_ALLERGENS $WORD"
				fi
				;;
		esac
	done

	for ALLERGEN in $LINE_ALLERGENS; do
		IFS='
'
		NEW_ALLERGEN_DATA="$ALLERGEN"
		OLD_ALLERGEN_DATA=''
		for ALLERGEN_DATA in $ALLERGENS; do
			case "$ALLERGEN_DATA" in
				$ALLERGEN*) OLD_ALLERGEN_DATA=$ALLERGEN_DATA ;;
			esac
		done
		if [ -z "$OLD_ALLERGEN_DATA" ]; then
			NEW_ALLERGEN_DATA="$ALLERGEN$LINE_INGREDIENTS"
			ALLERGENS="$NEW_ALLERGEN_DATA
$ALLERGENS"
		else
			IFS=' '
			for INGREDIENT in $LINE_INGREDIENTS; do
				case "$OLD_ALLERGEN_DATA" in
					*$INGREDIENT*) NEW_ALLERGEN_DATA="$NEW_ALLERGEN_DATA $INGREDIENT" ;;
				esac
			done
			ALLERGENS=`echo "$ALLERGENS" | sed "s/^$ALLERGEN .*/$NEW_ALLERGEN_DATA/"`
		fi
	done
done

NON_ALLERGENS=''
IFS=' '
for INGREDIENT in $INGREDIENTS; do
	FOUND=''
	for ALLERGEN_DATA in $ALLERGENS; do
		case $ALLERGEN_DATA in
			*$INGREDIENT*) FOUND=1; break;;
		esac
	done
	if [ -z "$FOUND" ]; then
		NON_ALLERGENS="$NON_ALLERGENS $INGREDIENT"
	fi
done

ANSWER1=0
IFS=' 
'
for WORD in $INPUT; do
	case "$NON_ALLERGENS" in
		*$WORD*) ANSWER1=$(( ANSWER1 + 1 )) ;;
	esac
done

N=`echo "$ALLERGENS" | wc -l`
USED_INGREDIENTS=''
FOUND_ALLERGENS=''

while [ $N -gt 0 ]; do
	IFS='
'
	for ALLERGEN_DATA in $ALLERGENS; do
		I=0
		ALLERGEN=''
		ALLERGEN_INGREDIENT=''
		IFS=' '
		for INGREDIENT in $ALLERGEN_DATA; do
			if [ -z "$ALLERGEN" ]; then
				ALLERGEN=$INGREDIENT
			else
				case "$USED_INGREDIENTS" in
					*$INGREDIENT*) ;;
					*) I=$(( I + 1 )); ALLERGEN_INGREDIENT=$INGREDIENT ;;
				esac
			fi
		done
		if [ $I -eq 1 ]; then
			N=$(( N - 1 ))
			USED_INGREDIENTS="$USED_INGREDIENTS $ALLERGEN_INGREDIENT"
			FOUND_ALLERGENS="$ALLERGEN	$ALLERGEN_INGREDIENT
$FOUND_ALLERGENS"
		fi
	done
done

ANSWER2=`echo -n \`echo -n "$FOUND_ALLERGENS" | sort | cut -f2\` | tr '\n' ','`

echo '--- Day 21: Allergen Assessment ---'
echo " Answer 1: $ANSWER1"
echo " Answer 2: $ANSWER2"
