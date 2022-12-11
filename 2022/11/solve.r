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

monkeys <- 0L
items <- list()
operations <- expression()
tests <- integer()
true <- integer()
false <- integer()

for (line in readLines(path)) {
	if (substr(line, 1, 7) == 'Monkey ') {
		monkeys <- monkeys + 1L
	} else if (line != '') {
		mode <- substr(line, 9, 9)
		if (mode == 'n') {
			items <- c(items, list(as.numeric(regmatches(line, gregexpr('[0-9]+', line))[[1]])))
		} else if (mode == 'i') {
			operations <- c(operations, parse(text=gsub('old', 'item', sub('^  Operation: new = ', '', line))))
		} else if (mode == 'd') {
			tests <- c(tests, as.integer(tail(strsplit(line, ' ')[[1]], 1)))
		} else if (mode == 'r') {
			true <- c(true, 1 + as.integer(tail(strsplit(line, ' ')[[1]], 1)))
		} else if (mode == 'a') {
			false <- c(false, 1 + as.integer(tail(strsplit(line, ' ')[[1]], 1)))
		}
	}
}

calculate <- function(rounds, divide) {
	common_multiple <- prod(tests)
	inspections = integer(monkeys)

	while (rounds > 0) {
		rounds <- rounds - 1L
		for (m in 1:monkeys) {
			for (item in items[[m]]) {
				inspections[m] <- inspections[m] + 1L
				item <- eval(operations[m]) %% common_multiple
				if (divide) {
					item <- item %/% 3
				}
				if (item %% tests[m] == 0) {
					items[[ true[m] ]] <- c(items[[ true[m] ]], item)
				} else {
					items[[ false[m] ]] <- c(items[[ false[m] ]], item)
				}
			}
			items[[m]] <- numeric()
		}
	}

	prod(tail(sort(inspections), 2))
}

answer1 <- calculate(20L, TRUE)
answer2 <- calculate(10000L, FALSE)

cat('--- Day 11: Monkey in the Middle ---\n')
cat(' Answer 1:', answer1, '\n')
cat(' Answer 2:', answer2, '\n')
