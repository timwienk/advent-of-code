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

calories <- c(0L)

for (line in as.integer(readLines(path))) {
	if (is.na(line)) {
		calories <- c(0L, calories)
	} else {
		calories[1] <- calories[1] + line
	}
}

calories <- sort(calories, TRUE)

answer1 <- calories[1]
answer2 <- sum(calories[1:3])

cat('--- Day 1: Calorie Counting ---\n')
cat(' Answer 1:', answer1, '\n')
cat(' Answer 2:', answer2, '\n')
