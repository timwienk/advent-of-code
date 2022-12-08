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

trees <- NULL

for (line in strsplit(readLines(path), '')) {
	if (is.null(trees)) {
		trees <- matrix(as.integer(line), ncol=length(line))
	} else {
		trees <- rbind(trees, as.integer(line))
	}
}

rows <- nrow(trees)
cols <- ncol(trees)

is_edge <- function(row, col) {
	edge <- any(c(
		row == c(1, rows), # Top and bottom rows
		col == c(1, cols)  # Left and right columns
	))

	edge
}

is_visible <- function(row, col) {
	visible <- is_edge(row, col)

	if (!visible) {
		best_path <- min(
			max(trees[row, 1:(col-1)]),    # Trees to the left
			max(trees[row, (col+1):cols]), # Trees to the right
			max(trees[1:(row-1), col]),    # Trees above
			max(trees[(row+1):rows, col])  # Trees below
		)

		visible <- (trees[row, col] > best_path)
	}

	visible
}

get_scenic_score <- function(row, col) {
	scores <- c(0L, 0L, 0L, 0L)

	if (!is_edge(row, col)) {
		tree <- trees[row, col]

		# Trees to the left
		for (t in rev(trees[row, 1:(col-1)])) {
			scores[1] <- scores[1] + 1L
			if (t >= tree) {
				break
			}
		}

		# Trees to the right
		for (t in trees[row, (col+1):cols]) {
			scores[2] <- scores[2] + 1L
			if (t >= tree) {
				break
			}
		}

		# Trees above
		for (t in rev(trees[1:(row-1), col])) {
			scores[3] <- scores[3] + 1L
			if (t >= tree) {
				break
			}
		}

		# Trees below
		for (t in trees[(row+1):rows, col]) {
			scores[4] <- scores[4] + 1L
			if (t >= tree) {
				break
			}
		}
	}

	prod(scores)
}

answer1 <- 0L
answer2 <- 0L

for (row in seq(1, rows)) {
	for (col in seq(1, cols)) {
		if (is_visible(row, col)) {
			answer1 <- answer1 + 1L
		}
		answer2 <- max(answer2, get_scenic_score(row, col))
	}
}

cat('--- Day 8: Treetop Tree House ---\n')
cat(' Answer 1:', answer1, '\n')
cat(' Answer 2:', answer2, '\n')
