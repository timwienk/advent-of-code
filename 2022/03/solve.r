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

rucksacks <- list()

for (line in strsplit(readLines(path), '')) {
	rucksacks <- c(rucksacks, list(line))
}

priorities <- c(letters, LETTERS)

answer1 <- 0L
answer2 <- 0L

for (rucksack in rucksacks) {
	count <- length(rucksack)
	half <- count %/% 2
	for (item in rucksack[1:half]) {
		if (item %in% rucksack[(half+1):count]) {
			answer1 <- answer1 + which(item == priorities)
			break
		}
	}
}

for (i in seq(1L, length(rucksacks), 3L)) {
	for (item in rucksacks[[i]]) {
		if (item %in% rucksacks[[i+1]] & item %in% rucksacks[[i+2]]) {
			answer2 <- answer2 + which(item == priorities)
			break
		}
	}
}

cat('--- Day 3: Rucksack Reorganization ---\n')
cat(' Answer 1:', answer1, '\n')
cat(' Answer 2:', answer2, '\n')
