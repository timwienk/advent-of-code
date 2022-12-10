#!/usr/bin/env Rscript

all_args <- commandArgs(trailingOnly=FALSE)
args <- commandArgs(trailingOnly=TRUE)
if (all_args[1] == 'RStudio') {
	library('rstudioapi')
	path <- rstudioapi::getSourceEditorContext()$path
} else {
	path <- tail(c('.', gsub('^(?:|--file=)(.*)$', '\\1', all_args[c(which(all_args == '-f') + 1, which(grepl('^--file=', all_args)))])), 1)
}
path <- file.path(normalizePath(dirname(path)), ifelse(length(args)>0, args[1], 'input'))

instructions <- character()

for (instruction in strsplit(readLines(path), ' ')) {
	instructions <- c(instructions, instruction)
}

cycle <- 0L
X <- 1L
addx <- FALSE
crt <- matrix(rep(FALSE, 6*40), nrow=6, ncol=40)

answer1 <- 0L
answer2 <- character()

for (instruction in instructions) {
	row <- cycle%/%40 + 1L
	col <- cycle%%40 + 1L
	cycle <- cycle + 1L

	if (col == 20) {
		answer1 <- answer1 + X*cycle
	}

	if (any(col == c(X, X+1, X+2))) {
		crt[row, col] <- TRUE
	}

	if (addx) {
		X <- X + as.integer(instruction)
		addx <- FALSE
	} else if (instruction == 'addx') {
		addx <- TRUE
	}
}

characters <- c(
	'222422' = 'A',
	'323223' = 'B',
	'221122' = 'C',
	'322223' = 'D',
	'413114' = 'E',
	'413111' = 'F',
	'221323' = 'G',
	'224222' = 'H',
	'311113' = 'I',
	'211122' = 'J',
#	'222222' = 'K',
	'111114' = 'L',
	'242222' = 'M',
	'233222' = 'N',
#	'222222' = 'O',
	'322311' = 'P',
#	'222222' = 'Q',
	'322322' = 'R',
	'312113' = 'S',
	'411111' = 'T',
#	'222222' = 'U',
	'222221' = 'V',
	'222242' = 'W',
#	'222222' = 'X',
	'222111' = 'Y',
	'411114' = 'Z'
)

# Extra checks for the characters we can't match by amount of lit pixels per line
character_checks <- list(
	'K' = list(c(3, 2)),
	'O' = list(c(2, 1), c(3, 6)),
	'Q' = list(c(2, 1), c(3, 5)),
	'U' = list(c(1, 1), c(3, 6)),
	'X' = list(c(3, 3))
)

for (n in 1:8) {
	char <- crt[,(1+(n-1)*5):(4+(n-1)*5)]

	pattern <- character()
	for (row in 1:nrow(crt)) {
		pattern <- paste(c(pattern, sum(char[row,])), collapse='')
	}

	value <- '_'
	if (pattern %in% names(characters)) {
		value <- characters[pattern]
	} else if (pattern == '222222') {
		for (option in names(character_checks)) {
			match <- TRUE
			for (check in character_checks[option][[1]]) {
				if (!char[check[2],check[1]]) {
					match <- FALSE
					break
				}
			}
			if (match) {
				value <- option
				break
			}
		}
	}

	answer2 <- paste(c(answer2, value), collapse='')
}

for (row in 1:nrow(crt)) {
	for (col in 1:ncol(crt)) {
		cat(ifelse(crt[row, col], '#', ' '))
	}
	cat('\n')
}

cat('--- Day 10: Cathode-Ray Tube ---\n')
cat(' Answer 1:', answer1, '\n')
cat(' Answer 2:', answer2, '\n')
