#!/bin/sh
set -efuC

DIR=`readlink -m \`dirname $0\``
if [ $# -gt 0 ]; then
	FILE="$DIR/$1"
else
	FILE="$DIR/input"
fi

INPUT=`sed 's/^./& /' "$FILE"`

calculate_ship_movement(){
	X=0
	Y=0
	R=90

	IFS='
	'
	for LINE in $INPUT; do
		IFS=' '
		for PART in $LINE; do
			case $PART in
				[A-Z]) ACTION=$PART ;;
				*) VALUE=$PART ;;
			esac
		done
		case $ACTION in
			N) Y=$(( Y + VALUE )) ;;
			S) Y=$(( Y - VALUE )) ;;
			E) X=$(( X + VALUE )) ;;
			W) X=$(( X - VALUE )) ;;
			L) R=$(( (R - VALUE + 360) % 360 )) ;;
			R) R=$(( (R + VALUE) % 360 )) ;;
			F)
				case $R in
					0) Y=$(( Y + VALUE )) ;;
					90) X=$(( X + VALUE )) ;;
					180) Y=$(( Y - VALUE )) ;;
					270) X=$(( X - VALUE )) ;;
				esac
				;;
		esac
	done

	if [ $X -lt 0 ]; then
		X=$(( -X ))
	fi
	if [ $Y -lt 0 ]; then
		Y=$(( -Y ))
	fi

	echo $(( X + Y ))
}

calculate_ship_movement_by_waypoint(){
	SHIP_X=0
	SHIP_Y=0
	WP_X=10
	WP_Y=1

	IFS='
	'
	for LINE in $INPUT; do
		IFS=' '
		for PART in $LINE; do
			case $PART in
				[A-Z]) ACTION=$PART ;;
				*) VALUE=$PART ;;
			esac
		done
		case $ACTION in
			N) WP_Y=$(( WP_Y + VALUE )) ;;
			S) WP_Y=$(( WP_Y - VALUE )) ;;
			E) WP_X=$(( WP_X + VALUE )) ;;
			W) WP_X=$(( WP_X - VALUE )) ;;
			L)
				case $VALUE in
					90) NEW_Y=$WP_X; WP_X=$(( -WP_Y )); WP_Y=$NEW_Y ;;
					180) WP_X=$(( -WP_X )); WP_Y=$(( -WP_Y )) ;;
					270) NEW_X=$WP_Y; WP_Y=$(( -WP_X )); WP_X=$NEW_X ;;
				esac
				;;
			R)
				case $VALUE in
					90) NEW_X=$WP_Y; WP_Y=$(( -WP_X )); WP_X=$NEW_X ;;
					180) WP_X=$(( -WP_X )); WP_Y=$(( -WP_Y )) ;;
					270) NEW_Y=$WP_X; WP_X=$(( -WP_Y )); WP_Y=$NEW_Y ;;
				esac
				;;
			F) SHIP_X=$(( SHIP_X + WP_X * VALUE )); SHIP_Y=$(( SHIP_Y + WP_Y * VALUE ));;
		esac
	done

	if [ $SHIP_X -lt 0 ]; then
		SHIP_X=$(( -SHIP_X ))
	fi
	if [ $SHIP_Y -lt 0 ]; then
		SHIP_Y=$(( -SHIP_Y ))
	fi

	echo $(( SHIP_X + SHIP_Y ))
}

ANSWER1=`calculate_ship_movement`
ANSWER2=`calculate_ship_movement_by_waypoint`

echo '--- Day 12: Rain Risk ---'
echo " Answer 1: $ANSWER1"
echo " Answer 2: $ANSWER2"
