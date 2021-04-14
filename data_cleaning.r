# data_cleaning.r
# 
# Evan Meade
# 
# This script reads in the raw dataset and performs basic data cleaning.
# This includes trimming down to variables of interest and dealing with
# missing values.
# 

# Reading in .csv
data <- read.csv("Life Expectancy Data.csv")

# Trimming to columns of interest (R^2 > 0.4, excluding adult mortality)
predictors <- c("Schooling", "GDP", "Alcohol", "BMI", "percentage.expenditure",
                "Income.composition.of.resources", "HIV.AIDS",
                "thinness.5.9.years", "thinness..1.19.years")
cols <- c("Country", "Year", "Status", "Life.expectancy", predictors)
data <- data[cols]

# Fixing original source's typo in naming the columns
data$thinness.10.19.years <- data$thinness..1.19.years
data <- data[-(ncol(data) - 1)]
predictors <- c("Schooling", "GDP", "Alcohol", "BMI", "percentage.expenditure",
                "Income.composition.of.resources", "HIV.AIDS",
                "thinness.5.9.years", "thinness.10.19.years")
cols <- c("Country", "Year", "Status", "Life.expectancy", predictors)

# Removing rows which do not include life expectancy
data <- data[-which(is.na(data$Life.expectancy)), ]



# This basically does nothing, because the missing values aren't randomly
# distributed throughout the dataset; they are concentrated in certain
# variables of certain countries.


# Interpolating missing values
library(zoo)
interpolated_data <- data.frame()
approx_cols <- c("Year", predictors)
for (country in unique(data$Country))
{
  country_data <- data[which(data$Country == country), ]
  
  approx_data <- country_data[approx_cols]
  approx_data <- na.approx(approx_data)
  # approx_data$Country <- country_data$Country
  # approx_data$Status <- country_data$Status
  # approx_data$Life.expectancy <- country_data$Life.expectancy
  approx_data <- cbind(approx_data, country_data[c("Country", "Status",
                                                   "Life.expectancy")])
  
  interpolated_data <- rbind(interpolated_data, approx_data)
}
interpolated_data <- interpolated_data[cols]







x <- data.frame(country = c(4, 1, 2, 3), Year = c(2003, 2004, 2006, 2007), value = c(0, 2, NA, 3), value2 = c(2, NA, NA, 1))
na.approx(x, x = x$Year)






# data$na.count <- rowSums(is.na(data))
# hist(data$na.count)
# table(data$na.count)

missing_values <- data.frame()
i <- 1
for (country in unique(data$Country))
{
  country_data <- data[which(data$Country == country), ]
  country_years <- sort(unique(country_data$Year))
  for (predictor in predictors)
  {
    reference <- FALSE
    for (year in country_years)
    {
      if (!is.na(country_data$predictor[which(country_data$Year == year)]))
      {
        reference <- TRUE
        
      } else {

      }
    }
    # missing_vector <- is.na(country_data[, predictor])
    # missing_years <- country_data$Year
    # names(missing_vector) <- missing_years
    # missing_vector[sort(names(missing_vector))]
    # missing_values[i, "var"] <- predictor
    # missing_values[i, "missing"] <- missing_vector
  }
}