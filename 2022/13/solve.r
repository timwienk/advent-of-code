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

parse <- function(line) {
	packet <- list()
	count <- length(line)
	index <- 1L

	while (count >= index) {
		char <- line[index]
		if (char == '[') {
			result <- parse(tail(line, -index))
			packet <- c(packet, list(result[[1]]))
			index <- index + result[[2]]
		} else {
			index <- index + 1L
			if (char == ']') {
				break
			} else if (char != ',') {
				nextchar = line[index]
				if (nextchar != ',' & nextchar != ']') {
					index <- index + 1L
					packet <- c(packet, list(as.integer(char)*10L+as.integer(nextchar)))
				} else {
					packet <- c(packet, list(as.integer(char)))
				}
			}
		}
	}

	list(packet, index)
}

compare <- function(left, right) {
	result <- 0L

	index <- 1L
	nleft <- length(left)
	nright <- length(right)
	while (index <= max(nleft, nright)) {
		if (index > nright) {
			result <- 1L
		} else if (index > nleft) {
			result <- -1L
		} else if (is.list(left[[index]]) | is.list(right[[index]])) {
			result <- compare(as.list(left[[index]]), as.list(right[[index]]))
		} else if (left[[index]] > right[[index]]) {
			result <- 1L
		} else if (right[[index]] > left[[index]]) {
			result <- -1L
		}
		if (result != 0L) {
			break
		}
		index <- index + 1L
	}

	result
}

packets <- list()
for (line in strsplit(readLines(path), '')) {
	if (length(line) > 0) {
		packet <- parse(line[-1])[[1]]
		packets <- c(packets, list(packet))
	}
}

answer1 <- 0L
answer2 <- 1L

pairs <- matrix(packets, ncol=2, byrow=TRUE)
for (R in 1:nrow(pairs)) {
	row <- pairs[R,]
	result <- compare(row[[1]], row[[2]])
	if (result < 1) {
		answer1 <- answer1 + R
	}
}

dividers <- c(2L, 6L)
for (divider in dividers) {
	packets <- c(packets, list(list(divider)))
}

class(packets) <- 'packetlist'
'[.packetlist' <- function(x, i) {
	structure(unclass(x)[i], class='packetlist')
}
'>.packetlist' <- function(left, right) {
	compare(left, right) == 1L
}
'==.packetlist' <- function(left, right) {
	compare(left, right) == 0L
}

packets <- sort(packets)

for (index in 1:length(packets)) {
	packet <- packets[[index]]
	if (length(packet) == 1) {
		if (is.integer(packet[[1]]) & length(packet[[1]]) == 1) {
			if (packet[[1]] %in% dividers) {
				answer2 <- answer2 * index
			}
		}
	}
}

cat('--- Day 13: Distress Signal ---\n')
cat(' Answer 1:', answer1, '\n')
cat(' Answer 2:', answer2, '\n')
