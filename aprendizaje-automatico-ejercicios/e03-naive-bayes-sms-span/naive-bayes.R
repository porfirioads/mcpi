# Título:   Detección de spam en SMS.
# Autor:    Porfirio Ángel Díaz Sánchez
# Creación: 21/05/2020

source('utils/packages.R')
install_missing_packages(c('tm', 'SnowballC', 'wordcloud', 'e1071'))

library(tm)
library(SnowballC)
library(wordcloud)
library(e1071)
library(gmodels)

# Importación de datos.
sms_raw <-
  read.csv('datasets/sms_spam.csv', stringsAsFactors = FALSE)

# Muestra información general del dataframe.
str(sms_raw)

# Como el atributo type es categórico, lo convierte a factor.
sms_raw$type  <- factor(sms_raw$type)

# Muestra atributo type para comprobar que fue convertido a factor.
str(sms_raw$type)

# Muestra los tipos de mensajes y su frecuencia.
table(sms_raw$type)

# Crea un corpus (colección de documentos de texto) con los sms.
sms_corpus <- VCorpus(VectorSource(sms_raw$text))

# Muestra la información del corpus.
print(sms_corpus)

# Muestra un resumen de los documentos especificados.
inspect(sms_corpus[1:2])

# Muestra el contenido del documento especificado.
as.character(sms_corpus[[1]])

# Muestra el contenido de los documentos especificados.
lapply(sms_corpus[1:3], as.character)

# Estandariza los mensajes para que estén en minúsculas.
sms_corpus_clean <- tm_map(sms_corpus, content_transformer(tolower))

# Comprueba la transformación.
as.character(sms_corpus[[1]])
as.character(sms_corpus_clean[[1]])

# Remueve números de los SMS.
sms_corpus_clean <- tm_map(sms_corpus_clean, removeNumbers)

# Remueve palabras no útiles para machine learning como and, to, but,
# or, etc.
sms_corpus_clean <-
  tm_map(sms_corpus_clean, removeWords, stopwords())

# Función que reemplaza signos de puntuación por espacios.
replacePunctuation <- function(x) {
  gsub("[[:punct:]]+", " ", x)
}

# Remueve signos de puntuación.
# sms_corpus_clean <- tm_map(sms_corpus_clean, replacePunctuation)
sms_corpus_clean <- tm_map(sms_corpus_clean, removePunctuation)

# Reduce palabras a su raíz.
sms_corpus_clean <- tm_map(sms_corpus_clean, stemDocument)

# Elimina espacios en blanco redundantes.
sms_corpus_clean <- tm_map(sms_corpus_clean, stripWhitespace)

# Reestablece a su tipo de dato original, que fue editado al momento
# de las transformaciones.
sms_corpus_clean <- tm_map(sms_corpus_clean, PlainTextDocument)

# Muestra ejemplos de los sms para comparar los textos originales con la
# transformación final. Como a sms_corpus_clean ya se le aplicaron
lapply(sms_corpus[1:3], as.character)
lapply(sms_corpus_clean[1:3], as.character)

# Separa los SMS en palabras creando un Document Term Matrix.
sms_dtm <- DocumentTermMatrix(sms_corpus_clean)

stopwords = function(x) {
  removeWords(x, stopwords())
}

# Crea el DTX con todas las transformaciones en un solo paso.
sms_dtm2 <- DocumentTermMatrix(
  sms_corpus,
  control = list(
    tolower = TRUE,
    removeNumbers = TRUE,
    stopwords = TRUE,
    removePunctuation = TRUE,
    stemming = TRUE
  )
)

# Crea datasets de entrenamiento y de prueba.
sms_dtm_train <- sms_dtm[1:4169, ]
sms_dtm_test <- sms_dtm[4170:5574, ]

# Crea vectores con las etiquetas del type para cada dataset.
sms_train_labels <- sms_raw[1:4169, ]$type
sms_test_labels <- sms_raw[4170:5574, ]$type

# Verifica los vectores creados para confirmar que son subconjuntos
# representativos de los datos:
prop.table(table(sms_train_labels))
prop.table(table(sms_test_labels))

# Muestra palabras más usadas en los mensajes.
wordcloud(sms_corpus_clean,
          min.freq = 50,
          random.order = FALSE)

# Crea subconjuntos de los sms por type.
spam <- subset(sms_raw, type == "spam")
ham <- subset(sms_raw, type == "ham")

# Muestra palabras más usadas por mensajes de spam y legítimos.
wordcloud(spam$text, max.words = 40, scale = c(3, 0.5))
wordcloud(ham$text, max.words = 40, scale = c(3, 0.5))

# Obtiene las palabras que aparecen al menos 5 veces.
sms_freq_words <- findFreqTerms(sms_dtm_train, 5)
str(sms_freq_words)
sms_dtm_freq_train <- sms_dtm_train[, sms_freq_words]
sms_dtm_freq_test <- sms_dtm_test[, sms_freq_words]

# Función para convertir las frecuencias a YES/NO.
convert_counts <- function(x) {
  x <- ifelse(x > 0, "Yes", "No")
}

# Aplica la conversión de las frecuencias en todas las filas y columnas.
# MARGIN = 2 es para indicar que estamos interesados en las columnas.
sms_train <- apply(sms_dtm_freq_train, MARGIN = 2,
                   convert_counts)
sms_test <- apply(sms_dtm_freq_test, MARGIN = 2,
                  convert_counts)

# Construye nuestro clasificador.
sms_classifier <- naiveBayes(sms_train, sms_train_labels)

# Realiza las predicciones en el dataset de prueba.
sms_test_pred <- predict(sms_classifier, sms_test)

# Compara las predicciones con los valores verdaderos.
CrossTable(
  sms_test_pred,
  sms_test_labels,
  prop.chisq = FALSE,
  prop.t = FALSE,
  dnn = c('predicted', 'actual')
)

# Modifica el valor de laplace, ya que con valor 0, permite que palabras
# que aparecieron solamente en los datos de entrenamiento tengan un valor
# indiscutible en el proceso de clasifiación.
sms_classifier2 <- naiveBayes(sms_train, sms_train_labels,
                              laplace = 1)

# Realiza la predicción.
sms_test_pred2 <- predict(sms_classifier2, sms_test)

# Compara la predicción con lo real.
CrossTable(sms_test_pred2, sms_test_labels,
           prop.chisq = FALSE, prop.t = FALSE, prop.r = FALSE,
           dnn = c('predicted', 'actual'))
