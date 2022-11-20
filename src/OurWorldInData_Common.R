library(tidyverse)
library(lubridate)
library(sparklyr)
library(DBI)
library(assertive)
library(readr)

source("FilePaths.R")
source("SparkFunctions.R")

#
# Load data
#
# Parameters:
#   verbose: TRUE to print progress
LoadDataset <- function(verbose = TRUE) {
    file_name <-
        Output.GetOurWorldInDataFilePath()
    
    cwd <- getwd()
    
    file_path <-
        paste0(cwd, "/", file_name)
    df <- readr::read_csv(file = file_path, col_names = TRUE)
    
    lat_long <- LoadCountryLatLong()
    
    df <-
        left_join(df, lat_long, by = c('iso_code' = 'Alpha-3 code'))
    
    df <- df |>
        mutate(date = as.Date(date, format = '%m/%d/%y'))
    df$year = format(df$date, '%Y')
    df$month = format(df$date, '%m')
    df$day = format(df$date, '%d')
    
    df <- AddScaledDeaths('deaths', df)
    
    return (df)
}

LoadCountryLatLong <- function() {
    file_name <-
        Output.GetCountryLatLongFilePath()
    
    cwd <- getwd()
    
    file_path <-
        paste0(cwd, "/", file_name)
    df <- readr::read_csv(file = file_path, col_names = TRUE)
    
    df <- rename(df, Longitude = `Longitude (average)`)
    df <- rename(df, Latitude = `Latitude (average)`)
    
    return (df)
}

AddScaledDeaths <- function(ts_type, df) {
    # add scaled variable for plotting purposes
    if (ts_type == 'deaths') {
        max_tot_deaths_per_million <-
            max(df$total_deaths_per_million, na.rm = TRUE)
        df <- df |>
            filter(!is.na(total_deaths_per_million)) |>
            mutate(scaled_var = total_deaths_per_million / max_tot_deaths_per_million)
    } else {
        max_confirmed <- max(df$confirmed)
        df <- df |>
            mutate(scaled_var = confirmed / max_confirmed)
    }
    return (df)
}

#
# Truncate data. For each Country/Province (global) or Province/State  (USA) keep latest observation,
# or x monthly observations, or x yearly observations.
#
# Parameters:
#   df: dataframe
# keep_type: truncation type c('last', 'month', 'year'). For month and year an optional count prefix
# may is allowed Example, '6 month' to keep semi-annual observations. First and last observations are
# always kep for month and year type.
#   global: TRUE if this is global data, FALSE for USA
Truncate <- function(df, keep_type = 'last', global) {
    n_days <- NULL
    if (str_detect(keep_type, 'month')) {
        n_days <- 30
        if (str_detect(keep_type, "[0-9]")) {
            count <- str_extract(keep_type, "[0-9]{1,2}")
            n_days <- n_days * as.integer(count)
        }
    } else {
        if (str_detect(keep_type, 'year')) {
            n_days <- 365
            if (str_detect(keep_type, "[0-9]")) {
                count <- str_extract(keep_type, "[0-9]{1,2}")
                n_days <- n_days * as.integer(count)
            }
        }
    }
    
    # keep only latest data? if so only keep last row
    if (keep_type == 'last') {
        df <-
            df |>
            group_by(location) |>
            filter(row_number() == n())
    } else if (str_detect(keep_type, 'month')) {
        df <-
            df |>
            group_by(location) |>
            filter(row_number() == 1 |
                       row_number() == n() |
                       row_number() %% n_days == 0)
    } else if (str_detect(keep_type, 'year')) {
        df <-
            df |>
            group_by(location) |>
            filter(row_number() == 1 |
                       row_number() == n() |
                       row_number() %% n_days == 0)
    }
    return (df)
}

# Copy dataframe to Spark.
#
# Parameters:
#   sc: Spark connection
#   df: dataframe'
#   name: name of dataframe in Spark
#   mamory TRUE to keep dataframe in Spark memory
#   verbode: TRUE to print progress
# Return:
#   Spark dataframe
#
CopyToSpark <- function(sc, df, name = 'covidata', memory = FALSE, verbose = TRUE) {
    sdf <- copy_to(
        sc,
        df,
        name = name,
        memory = memory,
        header = TRUE,
        overwrite = TRUE
    )
    
    if (verbose) {
        sdf_dim(sdf)
    }
    
    return (sdf)
}
