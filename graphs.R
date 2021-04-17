library(readr)
library(ggplot2)
life <- read_csv("Life-Expectancy-Data.csv")
View(life)

names(life) <- c("country", "year", "status", "life.expectancy", "adult.mortality", "infant.deaths",
                 "alcohol", "percent.expend", "hepB", "measles", "BMI", "under.five.deaths", "polio",
                 "total.expend", "diphtheria", "hiv.aids", "gdp", "population", "thinness.10.19",
                 "thinness.5.9", "income.comp.resources", "schooling")
ggplot(data = life, aes(x = Schooling, y = life.expectancy)) + geom_point(stat = "identity")
ggplot(data = life, aes(x = schooling, y = life.expectancy)) + geom_point(stat = "identity")
ggplot(data = life, aes(x = income.comp.resources, y = life.expectancy)) + geom_point(stat = "identity")
ggplot(data = life, aes(x = gdp, y = life.expectancy)) + geom_point(stat = "identity")
ggplot(data = life, aes(x = alcohol, y = life.expectancy)) + geom_point(stat = "identity")
ggplot(data = life, aes(x = BMI, y = life.expectancy)) + geom_point(stat = "identity")
ggplot(data = life, aes(x = income.comp.resources, y = life.expectancy)) + geom_point(stat = "identity")
ggplot(data = life, aes(x = percent.expend, y = life.expectancy)) + geom_point(stat = "identity")
ggplot(data = life, aes(x = hiv.aids, y = life.expectancy)) + geom_point(stat = "identity")
ggplot(data = life, aes(x = thinness.10.19, y = life.expectancy)) + geom_point(stat = "identity")
ggplot(data = life, aes(x = thinness.5.9, y = life.expectancy)) + geom_point(stat = "identity")
ggplot(data = life, aes(x = status, y = life.expectancy)) + geom_point(stat = "identity")
ggplot(data = life, aes(x = status, y = life.expectancy)) + geom_bar(stat = "identity")
