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

stacks <- list()
moves <- NULL

for (line in readLines(path)) {
	if (line == '') {
		moves <- list()
	} else if (is.null(moves)) {
		stack <- 0L
		for (char in seq(2, nchar(line), 4)) {
			stack <- stack + 1L
			crate <- substr(line, char, char)
			if (grepl('[^0-9 ]', crate)) {
				if (stack > length(stacks)) {
					stacks[[stack]] <- crate
				} else {
					stacks[[stack]] <- c(crate, stacks[[stack]])
				}
			}
		}
	} else {
		move <- as.integer(regmatches(line, gregexpr('[0-9]+', line))[[1]])
		names(move) <- c('count', 'from', 'to')
		moves <- c(moves, list(move))
	}
}

stacks1 <- stacks
for (move in moves) {
	crates <- rev(tail(stacks1[[ move['from'] ]], move['count']))
	stacks1[[ move['to'] ]] <- c(stacks1[[ move['to'] ]], crates)
	stacks1[[ move['from'] ]] <- head(stacks1[[ move['from'] ]], -move['count'])
}

stacks2 <- stacks
for (move in moves) {
	crates <- tail(stacks2[[ move['from']] ], move['count'])
	stacks2[[ move['to'] ]] <- c(stacks2[[ move['to'] ]], crates)
	stacks2[[ move['from'] ]] <- head(stacks2[[ move['from'] ]], -move['count'])
}

answer1 <- paste(sapply(stacks1, tail, 1), collapse='')
answer2 <- paste(sapply(stacks2, tail, 1), collapse='')

cat('--- Day 5: Supply Stacks ---\n')
cat(' Answer 1:', answer1, '\n')
cat(' Answer 2:', answer2, '\n')
