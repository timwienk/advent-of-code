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

pairs <- list()

for (line in strsplit(readLines(path), '[,-]')) {
	pairs <- c(pairs, list(matrix(as.integer(line), nrow=2, ncol=2, byrow=TRUE)))
}

answer1 <- 0L
answer2 <- 0L

for (pair in pairs) {
	if (pair[1,1] >= pair[2,1] & pair[1,2] <= pair[2,2] | pair[2,1] >= pair[1,1] & pair[2,2] <= pair[1,2]) {
		answer1 <- answer1 + 1L
		answer2 <- answer2 + 1L
	} else if (!(pair[1,1] > pair[2,2] | pair[2,1] > pair[1,2])) {
		answer2 <- answer2 + 1L
	}
}

cat('--- Day 4: Camp Cleanup ---\n')
cat(' Answer 1:', answer1, '\n')
cat(' Answer 2:', answer2, '\n')
