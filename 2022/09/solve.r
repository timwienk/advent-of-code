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

motions <- matrix(nrow=0, ncol=2)
colnames(motions) <- c('direction', 'steps')

for (line in strsplit(chartr('URDL', '1234', readLines(path)), ' ')) {
	motions <- rbind(motions, as.integer(line))
}

knots = matrix(rep(0L, 20), nrow=10, ncol=2)
colnames(knots) <- c('x', 'y')

knot1 <- 2
knot2 <- 10

history1 <- list(knots[knot1,])
history2 <- list(knots[knot2,])

for (motion in 1:nrow(motions)) {
	direction <- motions[motion, 'direction']
	steps <- motions[motion, 'steps']

	while (steps > 0) {
		steps <- steps - 1

		if (direction == 1) {
			knots[1, 'y'] <- knots[1, 'y'] + 1L
		} else if (direction == 2) {
			knots[1, 'x'] <- knots[1, 'x'] + 1L
		} else if (direction == 3) {
			knots[1, 'y'] <- knots[1, 'y'] - 1L
		} else if (direction == 4) {
			knots[1, 'x'] <- knots[1, 'x'] - 1L
		}

		for (index in 2:nrow(knots)) {
			h <- knots[index-1L,]
			t <- knots[index,]

			if (abs(h['x'] - t['x']) > 1) {
				t['x'] <- t['x'] + ifelse(h['x'] > t['x'], 1L, -1L)
				if (t['y'] != h['y']) {
					t['y'] <- t['y'] + ifelse(h['y'] > t['y'], 1L, -1L)
				}
			} else if (abs(h['y'] - t['y']) > 1) {
				t['y'] <- t['y'] + ifelse(h['y'] > t['y'], 1L, -1L)
				if (t['x'] != h['x']) {
					t['x'] <- t['x'] + ifelse(h['x'] > t['x'], 1L, -1L)
				}
			}

			knots[index,] = t
		}

		history1 <- union(history1, list(knots[knot1,]))
		history2 <- union(history2, list(knots[knot2,]))
	}
}

answer1 <- length(history1)
answer2 <- length(history2)

cat('--- Day 9: Rope Bridge ---\n')
cat(' Answer 1:', answer1, '\n')
cat(' Answer 2:', answer2, '\n')
