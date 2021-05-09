# Evan Meade, 2021

# 
# Begin Evan
# 

# Library imports
library(tidyverse)
library(car)

# Reading in the cleaned data
data <- read_csv("life_CLEAN.csv")
data


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
# End Evan
# 
