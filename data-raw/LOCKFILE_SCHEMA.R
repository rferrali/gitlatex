## code to prepare `LOCKFILE_SCHEMA` goes here
LOCKFILE_SCHEMA <- readLines("./data-raw/lockfile.schema.json")
usethis::use_data(LOCKFILE_SCHEMA, overwrite = TRUE)