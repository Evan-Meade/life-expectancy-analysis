library(readr)
library(ggplot2)
life <- read_csv("life_CLEAN.csv")
View(life)

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

## Question 7
ggplot(data = life, aes(x = percentage.expenditure, y = Life.expectancy, color = Status, alpha = 0.5 )) +
  geom_point(stat = "identity") +
  labs(x = "Percentage Expenditure for Healthcare of GDP", y = "Life Expectancy", 
       title = "Country spending towards healthcare vs. Life expectancy")


##Question 8

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





fit <- lm(Life.expectancy~Schooling+GDP+Alcohol+BMI+percentage.expenditure+
             Income.composition.of.resources+HIV.AIDS+thinness.5.9.years+thinness.10.19.years, data = life)
summary(fit)

fit0 <- lm(Life.expectancy~Schooling+GDP+Alcohol+BMI+percentage.expenditure+
            Income.composition.of.resources+HIV.AIDS+thinness.5.9.years+thinness.10.19.years, data = developed)

summary(fit0)

fit1 <- lm(Life.expectancy~Schooling+GDP+Alcohol+BMI+percentage.expenditure+
            Income.composition.of.resources+HIV.AIDS+thinness.5.9.years+thinness.10.19.years, data = developing)
summary(fit1)
