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

# Removing rows with any NA values
data <- data[-which(rowSums(is.na(data)) > 0), ]

# Writing cleaned data to a separate .csv file
write.csv(data, "life_CLEAN.csv", row.names = FALSE)
