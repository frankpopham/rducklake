#' Obtain information about the tables in the attached ducklake
#'
#' @inheritParams attach_ducklake
#' @param ducklake_alias of the ducklake attached to the duckdb connection (character)
#' @param table_name_only should the table names only or more detail be provided (default if TRUE)
#'
#' @returns a dataframe
#' @export
#'
#' @examples
ducklake_table_info <- function(conduckdb, ducklake_alias, table_name_only = TRUE) {

  check_duckdb_connection(conduckdb)

  stopifnot("table_name_only should be TRUE or FALSE (logical)" = is.logical(table_name_only))

  query <- glue::glue_sql("FROM ducklake_table_info({ducklake_alias});", .con = conduckdb)

  if(table_name_only) {
    dt <- DBI::dbGetQuery(conduckdb, query)["table_name"]
  } else {
    dt <- DBI::dbGetQuery(conduckdb, query)
  }
  return(dt)
}
