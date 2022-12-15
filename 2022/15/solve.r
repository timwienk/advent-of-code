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

limit1 <- 2000000L
limit2 <- 4000000L
if (endsWith(path, 'example')) {
	limit1 <- 10L
	limit2 <- 20L
}

sensors <- matrix(nrow=0,ncol=3)
beacons <- matrix(nrow=0,ncol=2)

for (line in readLines(path)) {
	line <- as.integer(regmatches(line, gregexpr('[0-9-]+', line))[[1]])
	distance <- abs(line[1]-line[3]) + abs(line[2]-line[4])
	sensors <- rbind(sensors, c(line[1:2], distance))
	if (line[4] == limit1) {
		# We only need the beacons on y=limit1
		beacons <- rbind(beacons, line[3:4])
	}
}
beacons <- unique(beacons)

is_beacon <- function(x, y) {
	beacon <- FALSE

	for (i in 1:nrow(beacons)) {
		if (x == beacons[i,1] & y == beacons[i,2]) {
			beacon <- TRUE
			break
		}
	}

	beacon
}

is_available <- function(x, y) {
	available <- TRUE

	for (i in 1:nrow(sensors)) {
		if (sensors[i,3] >= abs(sensors[i,1]-x) + abs(sensors[i,2]-y)) {
			available <- FALSE
			break
		}
	}

	available
}

offset1 <- max(sensors[,3]) - min(abs(limit1 - sensors[,2]))
offset2 <- 4000000

answer1 <- 0L
answer2 <- NULL

for (x in seq(min(sensors[,1]) - offset1, max(sensors[,1]) + offset1)) {
	# We need to check x from min(x)-max_distance to max(x)+max_distance
	if (!is_beacon(x, limit1)) {
		if (!is_available(x, limit1)) {
			answer1 <- answer1 + 1L
		}
	}
}

for (i in 1:nrow(sensors)) {
	sensor_x <- sensors[i,1]
	sensor_y <- sensors[i,2]
	distance <- sensors[i,3]

	# There is only one possible position, so if we check every edge+1 of
	# the sensor distances, we should find an available position
	for (dx in 0:(distance+1L)) {
		dy <- distance - dx + 1L
		for (x in c(sensor_x-dx, sensor_x+dx)) {
			for (y in c(sensor_y-dy, sensor_y+dy)) {
				if (x >= 0 & x <= limit2 & y >= 0 & y <= limit2) {
					if (is_available(x, y)) {
						answer2 <- format(x*offset2 + y, scientific=FALSE)
						break
					}
				}
			}
			if (!is.null(answer2)) {
				break
			}
		}
		if (!is.null(answer2)) {
			break
		}
	}
	if (!is.null(answer2)) {
		break
	}
}

cat('--- Day 15: Beacon Exclusion Zone ---\n')
cat(' Answer 1:', answer1, '\n')
cat(' Answer 2:', answer2, '\n')
