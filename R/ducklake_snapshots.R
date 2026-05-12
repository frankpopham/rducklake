#' Get details of updates (snapshots) to the ducklake
#'
#' @inheritParams ducklake_table_info
#'
#' @returns a dataframe
#' @export
#'
#' @examples
ducklake_snapshots <- function(conduckdb, ducklake_alias) {

  check_duckdb_connection(conduckdb)

  query <- glue::glue_sql("FROM ducklake_snapshots({ducklake_alias});", .con = conduckdb)

  DBI::dbGetQuery(conduckdb, query)
}
