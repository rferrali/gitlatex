## code to prepare `CONFIG_SCHEMA` goes here
.CONFIG_SCHEMA <- readLines("./data-raw/gitlatex.schema.json")
.CONFIG_PRIVATE_SCHEMA <- readLines("./data-raw/gitlatex.private.schema.json")
usethis::use_data(
  .CONFIG_SCHEMA, .CONFIG_PRIVATE_SCHEMA, 
  internal = TRUE, overwrite = TRUE
)
