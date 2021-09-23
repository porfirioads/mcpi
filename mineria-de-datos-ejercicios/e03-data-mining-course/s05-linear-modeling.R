#############################################
#####             Regression            #####
#############################################

# Regression works by building a function of independent
# variables (known as predictors) which predict one
# or more dependent variables (a response). For
# example, banks assess the risk of home-loam appli-
# cants based on their age, income, expenses, occu-
# pation, number of dependents, total credit limit, etc.

# We will look at an example of building a linear
# regression model to predict CPI data.

# Then we look at generalized linear models (GLMs)
# in the form of logistic and Poisson models (if have time).

# Linear regression predicts a response variable with
# a linear function of predictors:

# y = C0 + c1x1 + c2x2 + . . . + ckxk + e,

# where x1, x2, ... , xk are predictors, y is the
# response to predict and e is the error term.

# We demo regression with lm() function on the Australian
# CPI data from 2008 to 2010

### R code from vignette source 'ch-regression.rnw'

# free memory
rm(list = ls())
gc()

# create the data for each quarter 2008-2010
year <- rep(2008:2010, each=4)
year

# make quarters explicit ( 1-4 repeats 4 times)
quarter <- rep(1:4, 3)
quarter

# quarterly CPI data as a vector:
cpi <- c(162.2, 164.6, 166.5, 166.0,
         166.2, 167.0, 168.6, 169.5,
         171.0, 172.1, 173.3, 174.0)
cpi

# plot the data (suppressing x axis)
plot(cpi, xaxt="n", ylab="CPI", xlab="")
class(cpi)

# draw custom x-axis on bottom ('1'), 'las'
# makes it vertical:
axis(1, labels=paste(year,quarter,sep="Q"),
     at=1:12, las=3)

# correlations:
cor(year,cpi)
cor(quarter,cpi)

# build a linear regression model with cpi
# as predictor
fit <- lm(cpi ~ year + quarter)
fit
class(fit)
is.list(fit)
str(fit)

# summary() is better
summary(fit)

# So cpi is cpi = c0+c1*year+c2*quarter
# where co = intercept = -7644.4875
# c1 = 3.8875
# c2 = 1.1667

# what are fit$coefficients?
fit$coefficients
fit$coefficients[[1]]
fit$coefficients[[2]]
fit$coefficients[[3]]

# So the cpi for the 4 quarters of 2011 is:
(cpi2011 <- fit$coefficients[[1]] + fit$coefficients[[2]]*2011 +
  fit$coefficients[[3]]*(1:4))

# These commands provide more details of the model
attributes(fit)

# differences between observed values and fitted values
residuals(fit)

# to run residual and diagnostic plots
layout(matrix(c(1,2,3,4),2,2)) # 4 graphs per page
# plot is the lm() method that produces
# diagnostic plots of assumptions
plot(fit)
layout(matrix(1)) # change back to one graph per page

# scatterplot3d() creates 3D scatter plot
# and plane3d() draws the fitted plane. Parameter
# lab specifies the number of tickmarks on the
# x- and y-axes
library(scatterplot3d)
?scatterplot3d
s3d <- scatterplot3d(year, quarter, cpi, highlight.3d=T, type="h", lab=c(2,3))
s3d$plane3d(fit)

# With the model, the CPis in year 2011 can be
# predicted like this, with the predicted values
# shown as red triangles. First we set up df:
data2011 <- data.frame(year=2011, quarter=1:4)
data2011
# predict with regression fit
cpi2011 <- predict(fit, newdata=data2011)
cpi2011

# vector with '1' 12 times and '2' 4 times
style <- c(rep(1,12), rep(2,4))
# will vary plotting character and color with style
style

# suppress the x axis, define both plotting character
# and color by the 1's and 2's above
plot(c(cpi, cpi2011), xaxt="n",
     ylab="CPI", xlab="", pch=style, col=style)
# create custom x-axis
axis(1, at=1:16, las=3,
     # make x-axis labels on the fly
     labels=c(paste(year,quarter,sep="Q"),
              "2011Q1", "2011Q2", "2011Q3", "2011Q4"))

# More regression Hubble telescope
#### So how old is the universe?
install.packages("gamair")
library(gamair) # contains 'hubble'
data(hubble)
hub.mod <- lm(y~x-1,data=hubble)
summary(hub.mod)

#### Plot the residuals against the fitted values
plot(fitted(hub.mod),residuals(hub.mod),xlab="fitted values",ylab="residuals")

#### Omit offending points and produce new residual plot
hub.mod1 <- lm(y~x-1,data=hubble[-c(3,15),])
summary(hub.mod1)
plot(fitted(hub.mod1),residuals(hub.mod1),xlab="fitted values",ylab="residuals")

#### Estimate Hubble's Constant
hubble.const <- c(coef(hub.mod),coef(hub.mod1))/3.09e19
age <- 1/hubble.const
age/(60^2*24*365)

###############################################
#####     Generalized Linear Models      ######
###############################################

### Binomial models and heart disease (see GLM slides)

# Read in original Hand et al data from heart.csv
heart <- read.csv("c:/temp/heart.csv", header=T)
heart # to view the entire data set
head(heart) # to only view the first six rows

# Then plot the observed proportions of those who had a heart attack
# divided by the total number of patients:
p <- heart$ha /(heart$ha+heart$ok)
p

# Then plot the proportion as a function of increasing CK:
plot(heart$ck,p,xlab="Creatinine kinase level", ylab="Proportion Heart Attack")

# GLM call using cbind() to fit the heart attack model
mod.0 <- glm(cbind(ha,ok)~ck, family=binomial(link=logit), data=heart)
mod.0

#or we could have used since the logit link is the R default for binomial
mod.1 <- glm(cbind(ha,ok)~ck, family=binomial,data=heart)
mod.1

# Generate the model diagnostic plots
par(mfrow=c(2,2))
plot(mod.0)
# to reset graphic frame
layout(matrix(1))

# Plot the predicted heart attack levels (proportions)
plot(heart$ck,p,xlab="Creatinise kinase level", ylab="proportion Heart Attack")
lines(heart$ck,fitted(mod.0))

# Fit a second model with a cubic linear predictor
mod.2 <- glm(cbind(ha,ok)~ck+I(ck^2)+I(ck^3), family=binomial, data=heart)
mod.2

# Plot predicted heart attack levels (proportions) with the cubic model
par(mfrow=c(1,1))
plot(heart$ck,p,xlab="Creatinine kinase level", ylab="Proportion Heart Attack")
lines(heart$ck,fitted(mod.2))

# Calculate an 'analysis of deviance' table
anova(mod.0,mod.2,test="Chisq")

# A Poisson regression epidemic model (see GLM slides)

# Data provided by Venables and Ripley
y <- c(12,14,33,50,67,74,123,141,165,204,253,246,240)
t <- 1:13
plot(t+1980,y,xlab="Year",ylab="New AIDS Cases",ylim=c(0,280))

# Initial GLM model of counts of new cases modeled as a function of time
m0 <- glm(y~t,poisson)
m0

# Plot the residuals for the initial GLM
par(mfrow=c(2,2))
plot(m0)
# reset graphic frames
layout(matrix(1))

# Add a quadratic term with the time variable
m1 <- glm(y~t+I(t^2),poisson)
par(mfrow=c(2,2))
plot(m1)
# reset graphic frames
layout(matrix(1))
summary(m1)

# Perform an analysis of deviance of the two models
anova(m0,m1,test="Chisq")

