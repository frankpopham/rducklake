#' Create (or attach to an existing) duckdb database. This can be used to attach to the ducklake
#'
#' @param duckdbname duckdb database name (default is memory)
#'
#' @returns A duckdb database connection with two core extensions (ducklake and sqlite) installed and loaded
#'
#' @export
#'
#' @examples my_con <- connect_duckdb()
#' check_duckdb_connection(my_con)
#' disconnect_duckdb(my_con)
connect_duckdb <- function(duckdbname = NULL) {
  if (is.null(duckdbname)) {
    con <- DBI::dbConnect(duckdb::duckdb())
  } else {
    stopifnot("duckdbname argument should be a character" = is.character(duckdbname))

    con <- DBI::dbConnect(duckdb::duckdb(), dbdir = duckdbname)
  }

  DBI::dbSendQuery(con, "INSTALL ducklake;")
  DBI::dbSendQuery(con, "LOAD ducklake;")

  DBI::dbSendQuery(con, "INSTALL sqlite;")
  DBI::dbSendQuery(con, "LOAD sqlite;")

  return(con)
}

#' Check the connection is a duckdb connection
#'
#' @inheritParams attach_ducklake
#'
#' @returns NULL, no error means it is a dudkdb connection
#' @export
#'
#' @inherit connect_duckdb examples
check_duckdb_connection <-  function(conduckdb) {
  stopifnot("Not a duckdb connection" = class(conduckdb) == "duckdb_connection")

}


#' Disconnect from a duckdb connection
#'
#' @inheritParams attach_ducklake
#'
#' @returns Disconnects from a duckdb connection
#' @export
#'
#' @inherit connect_duckdb examples
#'
disconnect_duckdb <- function(conduckdb) {
  check_duckdb_connection(conduckdb)
  DBI::dbDisconnect(conduckdb)
}



