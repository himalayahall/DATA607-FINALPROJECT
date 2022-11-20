source('./Consts.R')

#
# Get full path to href file
# 
# Parameters:
#   file_type: c('href', 'ts')
#   global: TRUE for Global data file, FALSE for USA data file
Output.GetHrefFilePath <- function(file_type = 'href', global = FALSE) {
    source('./Consts.R')
    
    file_name <- NULL
    if (str_to_lower(file_type) == 'href') {
        if (global) {
            file_name <- DB.HREF_FILE_GLOBAL
        }
        else {
            file_name <- DB.HREF_FILE_USA
        }
    }
    else if (str_to_lower(file_type) == 'ts')
        # timestamp
    {
        if (global) {
            file_name <- DB.TS_FILE_GLOBAL
        }
        else {
            file_name <- DB.TS_FILE_USA
        }
    }
    else {
        print("Error: invalid file type")
        return (NA)
    }
    return (paste0(DB.SUMMARY_PATH, file_name, ".csv"))
}

#
# Get full path to data file
# 
# Parameters:
#   targetDate: MM-DD-YYYY
#   global: TRUE for Global data file, FALSE for USA data file
Output.GetDataFilePath <- function(targetDate, global = FALSE) {
    source('./Consts.R')
    
    file_name <- NULL
    
    target_year <- lubridate::year(targetDate)
    target_month <- toupper(lubridate::month(targetDate, label = TRUE, abbr = TRUE))
    
    if (global) {
        file_name <- paste0('global-', targetDate)
    }
    else {
        file_name <- paste0('usa-', targetDate)
    }
    
    return (paste0(DB.PATH, target_year, "/", target_month, "/", file_name, ".csv"))
}

Output.GetTimeSeriesFileName <- function(ts_type, global) {
    source('./Consts.R')
    
    library(assertive)
    
    assert_any_are_matching_fixed(ts_type, c("deaths", "confirmed"))
    file_name <- NULL
    if (global) {
        if (ts_type == "deaths") {
            file_name <- FILE.TS.GLOBAL.DEATHS
        } else {
            file_name <- FILE.TS.GLOBAL.CONFIRMED
        }
    } else {
        if (ts_type == "deaths") {
            file_name <- FILE.TS.US.DEATHS
        } else {
            file_name <- FILE.TS.US.CONFIRMED
        }
    }
    return (file_name)
}

#
# Get full path to time-series data.
# Parameters:
#   ts_type: time-series type: c('deaths', 'confirmed')
#   global: TRUE for global data, FALSE for USA
#
Output.GetTimeSeriesFilePath <- function(ts_type, global) {
    source('./Consts.R')
    
    file_name <- Output.GetTimeSeriesFileName(ts_type = ts_type, global = global)
    path <- paste0(DB.TIME_SERIES_PATH, file_name)
    return (path)
}

#
# Get full path to our-world-in-data data.
#
Output.GetOurWorldInDataFilePath <- function() {
    source('./Consts.R')
    
    file_name <- FILE.OUR_WORLD_IN_DATA
    path <- paste0(DB.OUR_WORLD_IN_DATA_PATH, file_name)
    return (path)
}

Output.GetCountryLatLongFilePath <- function() {
    source('./Consts.R')
    
    file_name <- FILE.COUNTRY_LAT_LONG
    path <- paste0(DB.OUR_WORLD_IN_DATA_PATH, file_name)
    return (path)
}

