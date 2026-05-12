#' Add a message to the snapshot when updating a ducklake table etc.
#'
#' @inheritParams ducklake_table_info
#' @param author author of the update
#' @param commit_message a message describing the update
#' @param commit_extra_info any extra information (default is NULL)
#' @param code the code making the change to the ducklake
#'
#' @returns a dataframe containing snapshots to date
#' @export
#'
#' @examples
commit_message <- function(conduckdb, ducklake_alias, author, commit_message, commit_extra_info = NULL, code) {

  DBI::dbWithTransaction(conduckdb, {code
  query <- glue::glue_sql("CALL {ducklake_alias}.set_commit_message({`author`}, {`commit_message`}, {`commit_extra_info`});",
                          .con = conduckdb)
  DBI::dbSendQuery(conduckdb, query)
  }
  )
ducklake_snapshots(conduckdb, ducklake_alias)

}
