# DATA607 - Final Project

## Ideas

1. Scrape Novel Coronavirus (COVID-19) [daily data](https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data/csse_covid_19_daily_reports_us) from JHU CSSE. Use parallel processing to efficiently scrape data
2. Scrape [timeseries](https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data/csse_covid_19_time_series) data, also from JHU CSSE
3. Scrape data from [Our World In Data](https://ourworldindata.org/coronavirus)
4. Enrich data - (a) mask/vaccination mandates in school and workplace)
5. [yRf](https://ropensci.org/blog/2022/07/26/package-yfr/) - S&P 500 dataset explored but not used for final presentation



6. Store data in Spark cluster using [sparklyr](https://rdrr.io/cran/sparklyr/)
7. EDA using Spark SQL
   - There are many cloud hosted Spark deployments - e.g. [Databricks Apache Spark](https://www.databricks.com/spark/about) and [AWS EM](https://aws.amazon.com/emr/features/spark/) - but the free tiers are time-limited. However, we can leverage a standalone Spark cluster as proof-of-concept. The standalone version provides ALL the functionality needed for implementing EDAs leveraging Spark.
8. EDA ideas
  > Hypothesis: mask mandates had an impact on infection rates, hispitalizations, and deaths
  
  > Hypothesis: school closures had an impact on infection rates, hispitalizations, and deaths
  
  > Hypothesis: incomes levels were correlated with infection rates, hispitalizations, and deaths
  
  > Hypothesis: race/age/gender were correlated with infection rates, hispitalizations, and deaths
  
 9. Explore displaying data in maps using [Leaflet](https://rstudio.github.io/leaflet/)

# Folders
1. data
   - source: original source data
   - processed: processed data
2. src - R source code
3. presentation - slideshow

# Milestones

- [x] Project Proposal
- [x] Acquire enrichment data
- [x] Create base helper Spark functions
- [x] Create base script to scrape JHU CSSE data
- [x] Create EDA using COVID and mask mandate data
- [x] Get around Github rate limits using Okta authentication
- [x] Enrich OWID data with latitude/longiture, tidy dataset
- [x] Load data into Spark cluster, perform Spark/ML
- [x] Create presentation slide deck using RMarkdown
- [x] Presentation

# Source code

See https://github.com/himalayahall/DATA607-FINALPROJECT/blob/master/src/README.md
