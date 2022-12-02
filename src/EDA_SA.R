library(tidyverse)
library(GGally) #to plot ggpairs
library(hrbrthemes) # add visualization theme

# covid data
covid.url <- "https://raw.githubusercontent.com/himalayahall/DATA607-FINALPROJECT/master/data/processed/owid/owid-covid-data.csv"
covid <- read_csv(covid.url)

# face covering data
fc.url <- "https://raw.githubusercontent.com/himalayahall/DATA607-FINALPROJECT/master/data/source/face-covering-policies-covid.csv"
fc <- read.csv(fc.url)

# rename columns in fc data to match
# convert date to date
fc <- fc |>
  rename(date = Day, iso_code = Code, location = Entity) |>
  mutate(date = as.Date(date))

# subset the covid data
covid.sub1 <- covid |> select(c(1:4,9,14,49,67))

## facet plot deaths by day by continent
ggplot(covid.sub1, aes(x=date, y=new_deaths, group=1)) +
  facet_wrap(~continent) +
  geom_line(color="#69b3a2") +
  labs(x = "Date", y = "Deaths", title = "Daily Covid Deaths by Continent")

### This appears to be aggregated data included in the dataset, let's filter this out and rerun the graphic
covid.sub1 <- covid |> select(c(1:4,8,9,14,49,67)) |>
  filter(!is.na(continent))

### re-run the graphic
ggplot(covid.sub1, aes(x=date, y=new_deaths, group=1)) +
  facet_wrap(~continent) +
  geom_line(color="#69b3a2") +
  labs(x = "Date", y = "Deaths", title = "Daily Covid Deaths by Continent")

# combine covid and face covering datasets
co.mask <- covid.sub1 |>
  left_join(fc, by=c("iso_code","location", "date"))

# save file - assumes current working directory is set to root folder of DATA607-FINALPROJECT
#filepath <- "/Users/joshiden/Documents/Classes/CUNY SPS/Fall 2022/DATA 607/DATA-607/PROJECTS/DATA607-FINALPROJECT/data/processed/covid_mask_combined.csv"
filepath <- "./data/processed/covid_mask_combined.csv"
write_csv(co.mask, filepath)

# read combined mask data
md <- "https://raw.githubusercontent.com/himalayahall/DATA607-FINALPROJECT/mask-data/data/processed/owid/covid_mask_combined.csv"
co.mask <- read_csv(md)

# avg mask rate by continent by year
co.mask |> na.omit() |>
  mutate(year = strftime(date, "%Y")) |>
  group_by(continent, year) |>
  summarize(avg_mask = mean(facial_coverings)) |>
  ggplot(aes(x = year, y = avg_mask, group=1)) +
  facet_wrap(~continent) +
  geom_col(fill="red") +
  labs(y = "avg", title = "Avg. Mask Rate - Continent")

# G7 countries
countries <- c("Canada","France","Germany","Italy","Japan","United Kingdom","United States")

# avg mask rate amongst G7 countries
co.mask |> na.omit() |>
  filter(location %in% countries) |>
  mutate(year = strftime(date, "%Y")) |>
  group_by(location, year) |>
  summarize(avg_mask = mean(facial_coverings)) |>
  ggplot(aes(x = year, y = avg_mask, group=1)) +
  facet_wrap(~location) +
  geom_col(fill="red") +
  labs (y = "avg", title = "Avg. Mask Rate - G7 Countries")

# how many observations of excess mortality are present in the dataset
sum(!is.na(co.mask$excess_mortality_cumulative_per_million))

# subset excess mortality
co.em <- co.mask |>
  filter(!is.na(excess_mortality_cumulative_per_million)) |>
  select(1:4,7:8) |>
  rename(excess = excess_mortality_cumulative_per_million,
         face = facial_coverings)

head(co.em)
# plot excess mortality against mask policy
boxplot(excess ~ face, co.em, main="distribution by policy", xlab="policy", ylab="excess deaths")

# facet histogram excess deaths by mask policy
ggplot(co.em, aes(x=excess)) +
  facet_wrap(~face) +
  geom_histogram(binwidth=sqrt(nrow(co.em))) +
  theme(axis.text.x = element_text(angle = 45, hjust=1)) +
  labs(title = "Histogram of Excess Death Totals by Mask Policy")

# total excess deaths by avg mask policy
co.em |> na.omit() |>
  group_by(location) |>
  summarize(total_excess = sum(excess), avg_policy = mean(face)) |>
  ggplot(aes(x=avg_policy, y=total_excess)) +
  geom_point()

### Mask policy vs total death p million
mask <- co.mask |>
  na.omit() |>
  group_by(iso_code) |>
  summarize(total_deaths_per_million = sum(total_deaths_per_million),
            avg_mask_policy = mean(facial_coverings),
            population_density = mean(population_density))

# mask by total death regression plot
ggplot(data = mask, aes(x = avg_mask_policy, y = total_deaths_per_million)) +
  geom_point() +
  stat_smooth(method = "lm", se = FALSE)

# mask by pop density regression plot
ggplot(data = mask, aes(x = population_density, y = total_deaths_per_million)) +
  geom_point() +
  stat_smooth(method = "lm", se = FALSE)

### Subsetting Covid data by Shiny app
cols <- c('location',
          'total_deaths_per_million',
          'excess_mortality_cumulative_per_million',
          'hosp_patients_per_million',
          'total_cases_per_million',
          'positive_rate',
          'total_vaccinations_per_hundred',
          'population_density',
          'gdp_per_capita')

covid.sub <- covid |>
  select(all_of(cols)) |>
  na.omit() 

# view pairs plots to identify possible linear relationships
ggpairs(covid.sub)

# subset and aggregate the data
covid.sub2 <- covid.sub |>
  group_by(location) |>
  summarize(total_deaths_per_million = sum(total_deaths_per_million),
            total_cases_per_million = sum(total_cases_per_million),
            population_density = mean(population_density),
            gdp_per_capita = mean(gdp_per_capita))

# view pairs plots of aggregated data
ggpairs(covid.sub2[,2:5])

### subset the mask data for linear modeling
co.mask.model.sub <- co.mask |> 
  na.omit() |>
  group_by(iso_code) |>
  summarize(excess_deaths = max(excess_mortality_cumulative_per_million),
            population_density = mean(population_density),
            mask_policy = mean(facial_coverings))

# create the model with both population density and mask policy
co.mask.model1 <- lm(excess_deaths ~ population_density + mask_policy, co.mask.model.sub)
summary(co.mask.model1)

# remove pop density
co.mask.model2 <- lm(excess_deaths ~ mask_policy, co.mask.model.sub)
summary(co.mask.model2)
