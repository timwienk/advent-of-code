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

map <- NULL
S1 <- list()
S2 <- list()
E <- NULL

R <- 0L
for (line in strsplit(readLines(path), '')) {
	R <- R + 1L
	if (is.null(map)) {
		map <- matrix(nrow=0, ncol=length(line))
	}
	row = integer()

	C <- 0L
	for (char in line) {
		C <- C + 1L
		if (char == 'S') {
			row <- c(row, 1L)
			S1 <- c(S1, list(c(R, C)))
			S2 <- c(S2, list(c(R, C)))
		} else if (char == 'a') {
			row <- c(row, 1L)
			S2 <- c(S2, list(c(R, C)))
		} else if (char == 'E') {
			row <- c(row, 26L)
			E <- c(R, C)
		} else {
			row <- c(row, which(char == letters))
		}
	}
	map <- rbind(map, c(row))
}

calculate <- function(start) {
	distance <- 0L

	queue <- list()
	for (coordinates in start) {
		queue <- c(queue, list(c(coordinates, 0L))) # (row, col, distance)
	}
	rows <- nrow(map)
	cols <- ncol(map)
	visited <- character()

	while (length(queue) > 0) {
		item <- queue[[1]]
		queue <- tail(queue, -1)

		if (!(paste(item[1:2], collapse=',') %in% visited)) {
			visited <- c(visited, paste(item[1:2], collapse=','))
			if (item[1] == E[1] & item[2] == E[2]) {
				distance <- item[3]
				break
			} else {
				max_height <- map[item[1], item[2]] + 1L
				for (R in c(item[1]-1L, item[1]+1L)) {
					if (R > 0 & R <= rows) {
						if (map[R, item[2]] <= max_height) {
							queue <- c(queue, list(c(R, item[2], item[3]+1L)))
						}
					}
				}
				for (C in c(item[2]-1L, item[2]+1L)) {
					if (C > 0 & C <= cols) {
						if (map[item[1], C] <= max_height) {
							queue <- c(queue, list(c(item[1], C, item[3]+1L)))
						}
					}
				}
			}
		}
	}

	distance
}

answer1 <- calculate(S1)
answer2 <- calculate(S2)

cat('--- Day 12: Hill Climbing Algorithm ---\n')
cat(' Answer 1:', answer1, '\n')
cat(' Answer 2:', answer2, '\n')
