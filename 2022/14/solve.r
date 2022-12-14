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

occupied <- character()
max_y <- 0L

for (line in strsplit(readLines(path), ' -> |,')) {
	structure <- matrix(as.integer(line), ncol=2, byrow=TRUE)
	max_y <- max(max_y, structure[,2])
	for (i in 2:nrow(structure)) {
		for (x in min(structure[(i-1):i, 1]):max(structure[(i-1):i, 1])) {
			for (y in min(structure[(i-1):i, 2]):max(structure[(i-1):i, 2])) {
				occupied <- union(occupied, paste(c(x, y), collapse=','))
			}
		}
	}
}

start_x <- 500L
start_y <- 0L
start <- paste(c(start_x, start_y), collapse=',')
rocks <- length(occupied)

answer1 <- 0L
answer2 <- 0L

stack <- character()
while (TRUE) {
	x <- start_x
	y <- start_y

	while (TRUE) {
		if (y > max_y) {
			if (!answer1) {
				answer1 <- length(occupied) - rocks
			}
			occupied <- union(occupied, paste(c(x, y), collapse=','))
			break
		} else {
			if (!(paste(c(x, y+1L), collapse=',') %in% occupied)) {
				stack <- union(paste(c(x, y), collapse=','), stack)
				y <- y + 1L
			} else if (!(paste(c(x-1L, y+1L), collapse=',') %in% occupied)) {
				stack <- union(paste(c(x, y), collapse=','), stack)
				x <- x - 1L
				y <- y + 1L
			} else if (!(paste(c(x+1L, y+1L), collapse=',') %in% occupied)) {
				stack <- union(paste(c(x, y), collapse=','), stack)
				x <- x + 1L
				y <- y + 1L
			} else {
				previous <- as.integer(strsplit(stack[1], ',')[[1]])
				stack <- stack[-1]
				start_x <- previous[1]
				start_y <- previous[2]
				occupied <- union(occupied, paste(c(x, y), collapse=','))
				break
			}
		}
	}

	if (start %in% occupied) {
		answer2 <- length(occupied) - rocks
		break
	}
}

cat('--- Day 14: Regolith Reservoir ---\n')
cat(' Answer 1:', answer1, '\n')
cat(' Answer 2:', answer2, '\n')
