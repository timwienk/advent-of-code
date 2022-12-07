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

sizes <- list('/'=0L)
dir <- character()

for (line in strsplit(readLines(path), ' ')) {
	if (line[1] == '$' & line[2] == 'cd') {
		if (line[3] == '/') {
			dir <- ''
		} else if (line[3] == '..') {
			dir <- head(dir, -1)
		} else {
			dir <- c(dir, line[3])
			sizes[[paste(dir, collapse='/')]] <- 0L
		}
	} else if (line[1] != '$' & line[1] != 'dir') {
		for (i in seq(1, length(dir))) {
			name <- ifelse(i > 1, paste(dir[1:i], collapse='/'), '/')
			sizes[[name]] <- sizes[[name]] + as.integer(line[1])
		}
	}
}

filesystem <- 70000000L
limit1 <- 100000L
limit2 <- 30000000L - (filesystem - sizes[['/']])

answer1 <- 0L
answer2 <- filesystem

for (size in sizes) {
	if (size <= limit1) {
		answer1 <- answer1 + size
	}
	if (size >= limit2 & size < answer2) {
		answer2 <- size
	}
}

cat('--- Day 7: No Space Left On Device ---\n')
cat(' Answer 1:', answer1, '\n')
cat(' Answer 2:', answer2, '\n')
