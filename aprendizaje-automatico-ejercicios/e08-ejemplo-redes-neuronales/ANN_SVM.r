##### Chapter 7: Neural Networks and Support Vector Machines #####

##### Neural Networks #####
##### Example: Modeling the Strength of Concrete  #####

# We'll predict concrete strength given the mixture components 

##### Step 1 – collecting data #####
# Data doneted by I-Cheng Yeh
# Available in: http://archive.ics.uci.edu/ml
# Dataset contains 1,030 examples of concrete with eight features 
# describing the components used in the mixture.
# (cemento, escoria, cenizas, agua, superplastificante, 
# agregado grueso, agregado fino y tiempo de envejecimiento)

install.packages('kernlab')
install.packages('neuralnet')

##### Step 2: Exploring and preparing the data #####
concrete <- read.csv('datasets/concrete.csv') #to read in data
str(concrete) # data structure

# Neural networks work best when the input data are scaled to 
# a narrow range around zero, so we need to normalize the data

# Creating the Normalization function
normalize <- function(x) { 
  return((x - min(x)) / (max(x) - min(x)))
}

# Normalizing the data frame
concrete_norm <- as.data.frame(lapply(concrete, normalize))
summary(concrete_norm$strength) # to verify normalization
summary(concrete$strength) # to compare with non-normalized

# Splitting the data into test and training sets
concrete_train <- concrete_norm[1:773, ]   # 75%
concrete_test <- concrete_norm[774:1030,]  # 25%

##### Step 3: Training a model on the data #####
# To model the relationship between the ingredients used in concrete 
# and the strength of the finished product, we will use a multilayer 
# feedforward neural network. The neuralnet package provides a 
# standard and easy-to-use implementation of such networks.
# It also offers a function to plot the network topology.

# There are several other commonly used packages to train ANN
# models in R, the nnet package is perhaps the most frequently 
# cited ANN implementation. It uses a slightly more sophisticated 
# algorithm than standard backpropagation. 
# Another strong option is the RSNNS package, which offers a 
# complete suite of neural network functionality with
# the downside being that it is more difficult to learn.

# Installation and loading
#install.packages(“neuralnet”)
library(neuralnet)


# Building the model 
set.seed(12345) # to guarantee the same results
concrete_model <- neuralnet(formula = strength ~ cement + slag +
                              ash + water + superplastic + 
                              coarseagg + fineagg + age,
                              data = concrete_train)
# It creates a simple ANN with only a single hidden neuron by default
# If more hidden layers are desired, they must be specified; hidden = X

plot(concrete_model) # To visualize the network topology
#The bias terms (indicated by the nodes labeled with the number 1), 
#are numeric constants that allow the value at the indicated nodes to be 
#shifted upward or downward, much like the intercept in a linear equation.

# The error representes the Sum of Squared Errors (SSE), which is the sum of 
# the squared predicted minus actual values. A lower SSE implies better
# predictive performance. This is helpful for estimating the model's performance on
# the training data, but tells us little about how it will perform on unseen data.

##### Step 4: Evaluating model performance #####
# To generate predictions on the test dataset, we can use the compute() function,
# which works a bit differently from the predict() functions we've used so far.
# It returns a list with two components: $neurons, which stores the neurons for 
# each layer in the network, and $net.result, which stores the predicted values. 
model_results <- compute(concrete_model, concrete_test[1:8])

predicted_strength <- model_results$net.result # To obtain predicted strength values

# This is a numeric prediction problem not a classification problem, so we cannot 
# use a confusion matrix to examine model accuracy. Instead, we must measure the 
# correlation between our predicted concrete strength and the true value. 
cor(predicted_strength, concrete_test$strength)
#Correlations close to 1 indicate strong linear relationships between two variables.

## Step 5: Improving model performance ----
# We will build a more complex neural network topology with 5 hidden neurons
set.seed(12345) # to guarantee repeatable results
concrete_model2 <- neuralnet(strength ~ cement + slag +
                               ash + water + superplastic + 
                               coarseagg + fineagg + age,
                               data = concrete_train, hidden = 5)

plot(concrete_model2) # To visualize the network topology
# The SSE has been reduced from 5.08 to 1.63.
# the number of training steps increase from 4,882 to 86,849,


# Evaluating the new results
model_results2 <- compute(concrete_model2, concrete_test[1:8])
predicted_strength2 <- model_results2$net.result
cor(predicted_strength2, concrete_test$strength)

##################################################################
##################################################################

##### Support Vector Machines ######
##### Example: Optical Character Recognition #####

# We'll try to convert printed or handwritten text into an electronic form 
# to be saved in a database

##### Step 1 – collecting data #####

# A OCR soffware first processes a document and divides the paper into a
# matrix such that each cell in the grid contains a single glyph (letrater, 
# symbol, or number). 
# Next, for each cell, the software will attempt to match the glyph to
# a set of all characters it recognizes.
# Finally, the individual characters would be combined back together into words

# We'll assume that we have already developed the algorithm to partition the 
# document into rectangular regions each consisting of a single character.
# We'll also assume the document contains only alphabetic characters in English.
# We'll simulate a process that involves matching glyphs to one of the 26 letters (A-Z).


# Data doneted by W. Frey and D. J. Slate
# Available in: http://archive.ics.uci.edu/ml
# Dataset contains 20,000 examples of 26 English alphabet capital letters printed
# using 20 different randomly reshaped and distorted black and white fonts.

##### Step 2: Exploring and preparing the data #####
# when the glyphs are scanned into the computer, they are converted into pixels 
# and 16 statistical attributes are recorded.
letters <- read.csv('datasets/letterdata.csv') #to read in data
str(letters) # data structure
summary(letters)

# Let's not normalize for now, because the R package that we will use for fitting
# the SVM model will perform the rescaling automatically.

# Splitting the data into test and training sets
letters_train <- letters[1:16000, ]     # 80%
letters_test  <- letters[16001:20000, ] # 20%

##### Step 3: Training a model on the data #####
install.packages("kernlab")
library(kernlab)

# Building the model using the ksvm() function
letter_classifier <- ksvm(letter ~ ., data = letters_train,
                          kernel = "vanilladot")
# "rbfdot" (radial basis)
# "polydot" (polinomial)
# "tanhdot" (hyperbolic tangent sigmoid)
# "vanilladot" (linear)

# to see basic information about the training parameters and the fit of the model
letter_classifier 

##### Step 4: Evaluating model performance #####
# To make predictions on testing dataset
letter_predictions <- predict(letter_classifier, letters_test)

head(letter_predictions) # to see the first six predicted letters

# Table to compare the predicted letter to the true letter in the testing dataset
table(letter_predictions, letters_test$letter)


# To indicat correct and incorrect predictions lets creat a vector of TRUE/FALSE
agreement <- letter_predictions == letters_test$letter 
table(agreement) # TRUE/FALSE table
prop.table(table(agreement))  # To see it in percentage 84%

## Step 5: Improving model performance ----
set.seed(12345)  # To get the same results time we run it 

# Let´s apply a different kernel (radial basis)
letter_classifier_rbf <- ksvm(letter ~ ., data = letters_train, kernel = "rbfdot")

# To make predictions on testing dataset
letter_predictions_rbf <- predict(letter_classifier_rbf, letters_test)

# To indicat correct and incorrect predictions lets creat a vector of TRUE/FALSE
agreement_rbf <- letter_predictions_rbf == letters_test$letter
table(agreement_rbf) # TRUE/FALSE table
prop.table(table(agreement_rbf)) # To see it in percentage 93%
