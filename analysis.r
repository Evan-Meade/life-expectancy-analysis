# Abraca-Data Code
# Team 11
# STAT 4355 - Spring 2021
# Prachi Patel, Evan Meade, Alejandro De La Cruz


# Imports
library(tidyverse)
library(corrplot)
library(janitor)
library(gganimate)
library(ggpubr)
library(ggthemes)
library(scales)
library(car)


# 
# Cleaning data
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


# Reading in cleaned data
data <- read_csv("life_CLEAN.csv")
data


# 
# Question 1 - Alejandro
# 

corrplot(cor(life[ , -c(1:3)]),
         type="upper",
         method = "number", 
         addCoefasPercent = FALSE)


# 
# Question 2 - Evan
# 

# Plotting each predictor against life expectancy
data %>% gather(Predictor, x, Schooling:thinness.10.19.years) %>%
  ggplot() +
  geom_point(aes(x, Life.expectancy, color = Predictor), alpha = 0.1) +
  geom_smooth(aes(x, Life.expectancy, group = Predictor),
              color = "black", method = "lm", se = FALSE) +
  facet_wrap(~ Predictor, scales = "free_x") +
  theme(legend.position = "none") +
  labs(title = "Scatter Plots of Life Expectancy vs. Each Predictor")


# 
# Question 3 - Alejandro
# 

model <- lm(life_expectancy ~ 
              (alcohol + percentage_expenditure + bmi + gdp + schooling + income_composition_of_resources + hiv_aids
               + thinness_1_19_years + thinness_5_9_years),
            data = life)

summary(model)
residualPlot(model, main = "Residual Plot of the Overall Model")
hist(model$residuals, breaks = 50, col = 'red', main = "Histogram of residuals - Overall Model", xlab = "Residuals Values")


# 
# Question 4 - Evan
# 

# Calculating average life expectancies for each year
year_averages <- aggregate(Life.expectancy ~ Year, data = data, FUN = mean)

# Plotting average national life expectancy over time
ggplot(data = year_averages, mapping = aes(x = Year, y = Life.expectancy)) +
  geom_line() +
  labs(title = "Average National Life Expectancy Over Time",
       x = "Year",
       y = "Average National Life Expectancy (Years)") +
  stat_smooth(method = "lm", se = FALSE, linetype = "dashed")

# Summarizing fit to year
summary(lm(Life.expectancy ~ Year, data = year_averages))

# Average life expectancies per year, with term for development status
status_averages <- aggregate(Life.expectancy ~ Year + Status, data = data, FUN = mean)

# Plotting developed vs. developing average life expectancies over time
ggplot(data = status_averages, mapping = aes(x = Year, y = Life.expectancy)) +
  geom_line(mapping = aes(color = Status)) +
  labs(title = "Average National Life Expectancy Over Time, By Development Status",
       x = "Year",
       y = "Average National Life Expectancy (Years)") +
  stat_smooth(mapping = aes(group = Status), method = "lm", se = FALSE,
              color = "black", size = 0.5, linetype = "dashed")

# Creating proxy variable for status
data$Status.proxy <- as.integer(factor(data$Status, levels = c("Developing",
                                                               "Developed"),
                                       labels = c(0, 1))) - 1

# Summary of fit to status proxy variable and year
summary(lm(Life.expectancy ~ Status.proxy + Year, data = data))


# 
# Question 5 - Evan
# 

# Fitting full model to the 7 selected predictors
model <- lm(Life.expectancy ~ Schooling + GDP + Alcohol + BMI +
              percentage.expenditure + Income.composition.of.resources +
              HIV.AIDS + thinness.5.9.years + thinness.10.19.years, data = data)
summary(model)

# Refining that model to significance
# Removing thinness.5.9.years due to high colinearity colinearity
vif(model)
model <- lm(Life.expectancy ~ Schooling + GDP + Alcohol + BMI +
              percentage.expenditure + Income.composition.of.resources +
              HIV.AIDS + thinness.10.19.years, data = data)
summary(model)

# Removing percentage expenditure for low significance
vif(model)
model <- lm(Life.expectancy ~ Schooling + GDP + Alcohol + BMI +
              Income.composition.of.resources +
              HIV.AIDS + thinness.10.19.years, data = data)
summary(model)

# Calculating predicted values and residuals for all entries
data$y.hat <- predict(model, data)
data$error <- data$Life.expectancy - data$y.hat

# Plotting histogram of residuals
ggplot(data = data) +
  geom_histogram(mapping = aes(x = error), binwidth = 1) +
  labs(title = "Residuals For All Life Expectancy Observations",
       x = "Residual (Years)",
       y = "Count")

# Plotting boxplots of residual distributions over time
ggplot(data = data) +
  geom_boxplot(mapping = aes(x = Year, group = Year, y = error)) +
  labs(title = "Residual Distributions Over Time",
       x = "Year",
       y = "Residual (Years)")

# Calculating p-value for each country's sample mean of the residual distribution,
# assuming a null hypothesis of following N(0, sigma^2)
rse <- summary(model)$sigma
av_error <- data %>%
  group_by(Country) %>%
  summarize(count = n(), total_error = sum(error), mean_error = total_error / count) %>%
  mutate(p_val = pnorm(abs(total_error), mean = 0, sd = sqrt(count) * rse, lower.tail = FALSE))

# Printing countries with statistically significant deviations from a mean residual
# distribution of 0
(signif_error <- av_error %>%
    filter(p_val < 0.001) %>%
    arrange(p_val))

# Plotting histogram of each nation's average residual
ggplot(data = av_error) +
  geom_histogram(mapping = aes(x = mean_error)) +
  labs(title = "Average Residuals of Each Nation",
       x = "Average Residual (Years)",
       y = "Count")

# Identifying top over- and under-performers by mean residual
outlier_order <- c(head(order(av_error$mean_error, decreasing = TRUE), 5),
                   tail(order(av_error$mean_error, decreasing = TRUE), 5))
av_error$over.rank <- order(av_error$mean_error, decreasing = TRUE)
outliers <- av_error$Country[outlier_order]
print(paste0(c("Top Over-perfomers: ", outliers[1:5])))
print(paste0(c("Top Under-perfomers: ", outliers[10:6])))
outlier_data <- data[which(data$Country %in% outliers), ]
outlier_data$Country <- factor(outlier_data$Country, levels = outliers)

# Plotting top 5 over- and under-performers by mean error
ggplot(data = outlier_data) +
  geom_line(mapping = aes(x = Year, y = error, color = Country)) +
  scale_color_brewer(palette = "RdYlGn", direction = -1) +
  labs(title = "Top Over- and Under-Performing National Life Expectancies",
       x = "Year",
       y = "Residual")


# 
# Question 6 - Alejandro
# 

model2 <- lm(life_expectancy ~ (alcohol + bmi + schooling + income_composition_of_resources + hiv_aids +   thinness_1_19_years),
             data = life)

summary(model2)
residualPlot(model2, main = "Residual Plot of the Reduced Model")
hist(model2$residuals, breaks = 50, col = 'red', main = "Histogram of residuals - Reduced Model", xlab = "Residuals Values")


# 
# Question 7 - Prachi
# 

ggplot(data = life, aes(x = percentage.expenditure, y = Life.expectancy, color = Status, alpha = 0.5 )) +
  geom_point(stat = "identity") +
  labs(x = "Percentage Expenditure for Healthcare of GDP", y = "Life Expectancy", 
       title = "Country spending towards healthcare vs. Life expectancy")


# 
# Question 8 - Prachi (and Alejandro)
# 

developed <- data.frame(life[which(life['Status'] == "Developed"),])
developing <- data.frame(life[which(life['Status'] != "Developed"),])

developed['Health'] <- developed['GDP'] * developed['percentage.expenditure']
developing['Health'] <- developing['GDP'] * developing['percentage.expenditure']


ggplot(data = developed, aes(x = Country,y = Health, color = Year)) + geom_point()
ggplot(data = developed, aes(x = Country,y = Life.expectancy, color = Year)) + geom_boxplot()

ggplot(data = developing, aes(x = Country,y = Life.expectancy, color = Year)) + geom_boxplot()


ggplot(data = developing, aes(x = Health,y = Life.expectancy)) + geom_point()+
  labs(x = "Spending in Dollars for Healthcare in Developing Nation", y = "Life Expectancy", 
       title = "Country spending towards healthcare vs. Life expectancy")
ggplot(data = developed, aes(x = Health,y = Life.expectancy)) + geom_point()+
  labs(x = "Spending in Dollars for Healthcare in Developed Nation", y = "Life Expectancy", 
       title = "Country spending towards healthcare vs. Life expectancy")


ggplot(data = life, aes(x = Status,y = Life.expectancy, color = Year)) + geom_boxplot()



fit <- lm(Life.expectancy~Schooling+GDP+Alcohol+BMI+Income.composition.of.resources+
            HIV.AIDS+thinness.10.19.years, data = life)
summary(fit)

fit0 <- lm(Life.expectancy~Schooling+GDP+Alcohol+BMI+percentage.expenditure+
             Income.composition.of.resources+HIV.AIDS+thinness.5.9.years+thinness.10.19.years, data = developed)

summary(fit0)

fit1 <- lm(Life.expectancy~Schooling+GDP+Alcohol+BMI+percentage.expenditure+
             Income.composition.of.resources+HIV.AIDS+thinness.5.9.years+thinness.10.19.years, data = developing)
summary(fit1)

# Alejandro
model_developed <- lm(life_expectancy ~ (alcohol + bmi + schooling +  percentage_expenditure + gdp +income_composition_of_resources  +  hiv_aids + thinness_1_19_years + thinness_5_9_years),
                      data = developed)
summary(model_developed)
residualPlot(model_developed, main = "Residual Plot of the Developed Model")
hist(model_developed$residuals, breaks = 50, col = 'red', main = "Histogram of residuals - Developed Model", xlab = "Residuals Values")

model_developing <- lm(life_expectancy ~ (alcohol + bmi + schooling +  percentage_expenditure + gdp +income_composition_of_resources + hiv_aids +   thinness_1_19_years + thinness_5_9_years),
                       data = developing)
summary(model_developing)
residualPlot(model_developing, main = "Residual Plot of the Developing Model")
hist(model_developing$residuals, breaks = 50, col = 'red', main = "Histogram of residuals - Developing Model", xlab = "Residuals Values")
