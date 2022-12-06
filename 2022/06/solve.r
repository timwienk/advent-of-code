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

datastream <- strsplit(readLines(path, 1), '')[[1]]

length1 <- 4L
length2 <- 14L

answer1 <- 0L
answer2 <- 0L

for (index in seq(min(length1, length2), length(datastream))) {
	if (!answer1 & index >= length1) {
		if (!anyDuplicated(datastream[(index-length1+1):index])) {
			answer1 <- index
		}
	}
	if (!answer2 & index >= length2) {
		if (!anyDuplicated(datastream[(index-length2+1):index])) {
			answer2 <- index
		}
	}
	if (answer1 & answer2) {
		break
	}
}

cat('--- Day 6: Tuning Trouble ---\n')
cat(' Answer 1:', answer1, '\n')
cat(' Answer 2:', answer2, '\n')
