DB.PATH <- "../data/processed/"
DB.SUMMARY_PATH <- paste0(DB.PATH, 'summary/')
DB.TIME_SERIES_PATH <- paste0(DB.PATH, 'timeseries/')
DB.OUR_WORLD_IN_DATA_PATH <- paste0(DB.PATH, 'owid/')
DB.COUNTRY_LAT_LONG_DATA_PATH <- paste0(DB.PATH, 'owid/')

DB.HREF_FILE_USA <- "usa_href"
DB.TS_FILE_USA <- "usa_ts"

DB.HREF_FILE_GLOBAL <- "global_href"
DB.TS_FILE_GLOBAL <- "global_ts"

# Daily reports
URL.BASE <-
    "https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data/csse_covid_19_daily_reports/csse_covid_19_data/"
URL.USA <-
    paste0(URL.BASE,
           "csse_covid_19_daily_reports_us")
URL.GLOBAL <-
    paste0(URL.BASE, "csse_covid_19_daily_reports")

# Time series
FILE.TS.US.DEATHS <- "time_series_covid19_deaths_US.csv"
URL.TS.US.DEATHS <-
    paste0(
        "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/",
        FILE.TS.US.DEATHS
    )

FILE.TS.US.CONFIRMED <- "time_series_covid19_confirmed_US.csv"
URL.TS.US.CONFIRMED <-
    paste0(
        "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/",
        FILE.TS.US.CONFIRMED
    )

FILE.TS.GLOBAL.CONFIRMED <-
    "time_series_covid19_confirmed_global.csv"
URL.TS.GLOBAL.CONFIRMED <-
    paste0(
        "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/",
        FILE.TS.GLOBAL.CONFIRMED
    )

FILE.TS.GLOBAL.DEATHS <- "time_series_covid19_deaths_global.csv"
URL.TS.GLOBAL.DEATHS <-
    paste0(
        "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/",
        FILE.TS.GLOBAL.DEATHS
    )

FILE.OUR_WORLD_IN_DATA <- "owid-covid-data.csv"
URL.OUR_WORLD_IN_DATA <-
    paste0(
        "https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/",
        FILE.OUR_WORLD_IN_DATA
    )

FILE.COUNTRY_LAT_LONG <- "country_lat_long.csv"

SELENIUM.PORT <- 4545L
