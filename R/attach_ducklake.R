#' Attach, create or update a ducklake
#'
#' @param conduckdb an existing duckdb connection
#' @param ducklake_filename file name (and directory if not in working directory) of ducklake
#' @param ducklake_alias short alias to use instead of ducklake_filename when referring to ducklake database
#' @param create_if_not_exists create a new ducklake if it does not already exist (default is FALSE)
#' @param read_only connect read only to the ducklake. if create_if_not_exists is TRUE this should be FALSE (default is TRUE)
#'
#' @param ducklake_type which SQL software to use as catalog for metadata (duckdb or sqlite)
#' @param ducklake_encrypt should the ducklake itself be encrypted (for duckdb only - default is TRUE)
#' @param parquet_encrypt should the parquet files storing tables be encrypted (default is TRUE)
#' @param parquet_directory directory where the parquet files are / should be stored (default is "data_files")
#' @param override_parquet_directory if data path is different to default should this overrides the default (default is FALSE)
#'
#' @returns Attaches the ducklake to your duckdb connection and with message confirming the ducklake is the default database.
#' Returns dataframe of attached databases.
#' @export
#'
#' @examples my_con <- connect_duckdb()
#'
#' attach_ducklake(my_con,
#'    ducklake_filename = tempfile(pattern = "metadata.ducklake"),
#'    ducklake_alias = "my_ducklake",
#'    create_if_not_exists = TRUE,
#'    read_only = FALSE,
#'    ducklake_encrypt = FALSE,
#'    parquet_directory = tempdir())
#'
#' switch_default_database(my_con, "memory")
#'
#' switch_default_database(my_con, "my_ducklake")
#'
#' detach_ducklake(my_con, "my_ducklake", "memory")

attach_ducklake <- function(conduckdb,
                            ducklake_filename  = NULL,
                            ducklake_alias = NULL,
                            create_if_not_exists = FALSE,
                            read_only = TRUE,
                            ducklake_type = "duckdb",
                            ducklake_encrypt = FALSE,
                            parquet_encrypt = FALSE,
                            parquet_directory = "data_files",
                            override_parquet_directory = FALSE) {

  check_duckdb_connection(conduckdb)

  stopifnot("ducklake_filename should be a character path to a ducklake" = is.character(ducklake_filename))

  stopifnot("ducklake_alias should be a character (such as my_ducklake)" = is.character(ducklake_alias))

  match.arg(ducklake_type, choices = c("duckdb", "sqlite"))

  if(ducklake_type == "sqlite" && ducklake_encrypt) {
    stop("If sqlite is the ducklake catalog, encryption of catalog not implemented yet")
  }

  # parameters

  cine <- glue::glue_sql("CREATE_IF_NOT_EXISTS {create_if_not_exists}", .con = conduckdb)

  da <- DBI::SQL(ducklake_alias)

  # type

  dt <- glue::glue_sql("META_TYPE {ducklake_type}", .con = conduckdb)

  df <- DBI::dbQuoteLiteral(conduckdb, paste0("ducklake:", ducklake_filename))

  if (ducklake_type == "duckdb" && ducklake_encrypt) {
    de <- DBI::SQL("META_ENCRYPTION_KEY ?")
  }


  pe <- glue::glue_sql("ENCRYPTED {parquet_encrypt}", .con = conduckdb)

  pd <- glue::glue_sql("DATA_PATH {parquet_directory}", .con = conduckdb)

  odp <- glue::glue_sql("OVERRIDE_DATA_PATH {override_parquet_directory}", .con = conduckdb)

  ro <- glue::glue_sql("READ_ONLY {read_only}", .con = conduckdb)

  # build for attach
  if(!create_if_not_exists & ducklake_encrypt) {
    attach_sql <- glue::glue_sql("ATTACH {df} AS {da} ({dt}, {cine}, {de}, {ro});", .con = conduckdb)
  } else if (!create_if_not_exists & !ducklake_encrypt) {
    attach_sql <- glue::glue_sql("ATTACH {df} AS {da} ({dt}, {cine}, {ro});", .con = conduckdb)
  } else if (create_if_not_exists &  ducklake_encrypt) {
    attach_sql <- glue::glue_sql("ATTACH {df} AS {da} ({dt}, {cine}, {pe}, {pd}, {odp}, {de}, {ro});", .con = conduckdb)
  } else {
    attach_sql <- glue::glue_sql("ATTACH {df} AS {da} ({dt}, {cine}, {pe}, {pd}, {odp}, {ro});", .con = conduckdb)
  }

  # attach

  if (ducklake_encrypt) {

    DBI::dbSendQuery(conduckdb, attach_sql, params = askpass::askpass())
  } else

  DBI::dbSendQuery(conduckdb, attach_sql)

  switch_default_database(conduckdb, da)

  attached_databases(conduckdb)

}

#' Switch the default database on a duckdb connection
#'
#' @inheritParams attach_ducklake
#' @param new_default the new_default database to switch to
#'
#' @returns the new default database
#' @export
#'
#' @inherit attach_ducklake examples
switch_default_database <- function(conduckdb, new_default) {

  check_duckdb_connection(conduckdb)

  pd <- DBI::SQL(new_default)

  use_sql <- glue::glue_sql("USE {`pd`};", .con = conduckdb)

  DBI::dbSendQuery(conduckdb, use_sql)

  default_database(conduckdb)

}

#' Check the current default database on a duckdb connection
#'
#' @inheritParams attach_ducklake
#'
#' @returns the name of the default database. Use `switch_default_database()` to change the default database
#' @export

default_database <- function(conduckdb) {

  check_duckdb_connection(conduckdb)

  cd <- as.character(DBI::dbGetQuery(conduckdb, "SELECT current_database();"))

  cd2 <- paste(cd, "is the default database")
  message(cd2)

  invisible(cd)

}

#' What databases are attached to the duckdb connection
#'
#' @inheritParams attach_ducklake
#'
#' @returns a dataframe with the attached database names
#' @export

attached_databases <- function(conduckdb) {

check_duckdb_connection(conduckdb)

ad <- DBI::dbGetQuery(conduckdb, "SHOW databases;")

names(ad) <- "attached_databases"

return(ad)
}

#' Detach a ducklake from a duckdb connection
#'
#' @inheritParams attach_ducklake
#' @param new_default A new default database (default is memory).
#' Run `attached_databases()` for a list of currently attached databases
#'
#' @returns detaches and returns remaining attached databases
#' @export
#'
#' @inherit attach_ducklake examples

detach_ducklake <- function(conduckdb, ducklake_alias, new_default = "memory") {

  check_duckdb_connection(conduckdb)

  switch_default_database(conduckdb = conduckdb, new_default = new_default)

  da <- DBI::SQL(ducklake_alias)

  detach_sql <- glue::glue_sql("DETACH {`da`};", .con = conduckdb)

  DBI::dbSendQuery(conduckdb, detach_sql)

  attached_databases(conduckdb)

}



