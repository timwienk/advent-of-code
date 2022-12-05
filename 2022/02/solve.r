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

moves <- list()

for (line in strsplit(chartr('ABCXYZ', '123123', readLines(path)), ' ')) {
	moves <- c(moves, list(as.integer(line)))
}

R <- 1L # Rock
P <- 2L # Paper
S <- 3L # Scissors

L <- 0L # Lose
D <- 3L # Draw
W <- 6L # Win

m1 <- matrix(
	c(
	#	[,1] Play R  [,2] Play P  [,3] Play S
		R+D,         P+W,         S+L,        # [1,] vs. R
		R+L,         P+D,         S+W,        # [2,] vs. P
		R+W,         P+L,         S+D         # [3,] vs. S
	),
	nrow=3,
	ncol=3,
	byrow=TRUE
)

m2 <- matrix(
	c(
	#	[,1] Lose    [,2] Draw    [,3] Win
		L+S,         D+R,         W+P,        # [1,] vs. R
		L+R,         D+P,         W+S,        # [2,] vs. P
		L+P,         D+S,         W+R         # [3,] vs. S
	),
	nrow=3,
	ncol=3,
	byrow=TRUE
)

answer1 <- 0L
answer2 <- 0L

for (move in moves) {
	answer1 <- answer1 + m1[move[1], move[2]]
	answer2 <- answer2 + m2[move[1], move[2]]
}

cat('--- Day 2: Rock Paper Scissors ---\n')
cat(' Answer 1:', answer1, '\n')
cat(' Answer 2:', answer2, '\n')
