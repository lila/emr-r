#! /usr/bin/env Rscript

conn <- file("stdin", open="r")
while (length(next.line <- readLines(conn, n=1)) > 0) {
  split.line <- strsplit(next.line, "\\|")
  if (as.numeric(split.line[[1]][2]) == 9) {
  write(paste(split.line[[1]][3], 
  gsub("[$,]", "", split.line[[1]][6]), sep="\t"), stdout())
  }
}
close(conn)
