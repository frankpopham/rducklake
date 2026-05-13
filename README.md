
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rducklake

<!-- badges: start -->

[![R-CMD-check](https://github.com/frankpopham/rducklake/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/frankpopham/rducklake/actions/workflows/R-CMD-check.yaml)

<!-- badges: end -->

rducklake runs a [ducklake](https://ducklake.select/) from R. It is an
alternative to the excellent
[ducklake-r](https://tgerke.github.io/ducklake-r/).

## Installation

You can install the development version of rducklake from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("frankpopham/rducklake")
```

## Example

### Create a ducklake

1.  Make a connection to a duckdb database. The default makes a
    temporary connection to a database in memory (RAM). The attached
    database function shows that the connection my_con has one database
    attached which is called memory.

``` r

library(rducklake)

my_con <- connect_duckdb() 

attached_databases(my_con)
```

2.  Create a new ducklake attached to the duckdb connection. Give it a
    name (and a directory if not thw working directory) via
    ducklake_path and an alias (which you use to reference it for this
    session). Set create_if_not_exists to TRUE. The rest of the
    arguments have “sensible” defaults as discussed below

The ducklake database (catalog) itself can be a duckdb (the default) or
sqlite database (at the moment). [See the ducklake documentation for a
discussion on choosing a catalog
database.](https://ducklake.select/docs/stable/duckdb/usage/choosing_a_catalog_database)

Encryption of the ducklake is only available for a duckdb based ducklake
(for sqlite set this option to false). You’ll be prompted to set a
password if you choose to encrypt. You can also encrypt the parquet
files that store the data in the ducklake. By default the parquet files
are stored in a directory called “data_files” in the working directory.
You can change this by giving another directory and/or name.

``` r
attach_ducklake(my_con,
                ducklake_path = "example.ducklake",
                ducklake_alias = "my_ducklake",
                create_if_not_exists = TRUE)
```

This Will prompt you to set a password for the ducklake (if opting for
the encrypted ducklake). You see a message that the ducklake is now the
default database confirming it has been attached.

Check your file directory from ducklake_path to check your ducklake has
been created with the ducklake_path name.

``` r
attached_databases(my_con)
```

You will now see that three databases are attached. The one starting
\_\_ is just the metadata for the ducklake and can be ignored. You then
have your ducklake (the default) and the original duckdb database

3.  Upload some data to the ducklake. As it is the default database you
    do not need to reference the ducklake when writing.

``` r

library(DBI)

dbWriteTable(my_con, "mtcars", mtcars)
```
