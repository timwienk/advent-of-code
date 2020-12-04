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

check_valid_keys(){
	if [ $# -lt 7 ]; then
		return 1
	elif [ $# -eq 7 ]; then
		for DATA in $@; do
			case "$DATA" in
				cid:*) return 1;;
			esac
		done
	fi
}
check_valid_values(){
	for DATA in $@; do
		case "$DATA" in
			byr:19[2-9][0-9]|byr:200[0-2]) ;;
			iyr:201[0-9]|iyr:2020) ;;
			eyr:202[0-9]|eyr:2030) ;;
			hgt:1[5-8][0-9]cm|hgt:19[0-3]cm) ;;
			hgt:59in|hgt:6[0-9]in|hgt:7[0-6]in) ;;
			hcl:\#[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]) ;;
			ecl:amb|ecl:blu|ecl:brn|ecl:gry|ecl:grn|ecl:hzl|ecl:oth) ;;
			pid:[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]) ;;
			cid:*) ;;
			*) return 1;;
		esac
	done
}

IFS='
'
for LINE in `tr "\n" ' ' < "$FILE" | sed -E 's/ ( |$)/\n/g'`; do
	IFS=' '
	if check_valid_keys $LINE; then
		ANSWER1=$(( $ANSWER1 + 1 ))
		if check_valid_values $LINE; then
			ANSWER2=$(( $ANSWER2 + 1 ))
		fi
	fi
done

echo '--- Day 4: Passport Processing ---'
echo " Answer 1: $ANSWER1"
echo " Answer 2: $ANSWER2"
