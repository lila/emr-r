#! /usr/bin/env Rscript

current.key <- NA
current.upb <- 0.0

conn <- file("stdin", open="r")
while (length(next.line <- readLines(conn, n=1)) > 0) {
  split.line <- strsplit(next.line, "\t")
  key <- split.line[[1]][1]
  upb <- as.numeric(split.line[[1]][2])
  if (is.na(current.key)) {
  current.key <- key
  current.upb <- upb
  }
  else {
  if (current.key == key) {
  current.upb <- current.upb + upb
  }
  else {
  write(paste(current.key, current.upb, sep="\t"), stdout())
  current.key <- key
  current.upb <- upb
  }
  }
}
write(paste(current.key, current.upb, sep="\t"), stdout())
close(conn)
