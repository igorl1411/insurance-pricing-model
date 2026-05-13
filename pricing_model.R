# Dane: Insurance Medical Cost Dataset (Kaggle)

library(tidyverse)

df <- read_csv("insurance.csv")
head(df)
summary(df)

# Analiza różnic w kosztach ze względu na bycie palaczem
analiza_palaczy <- df %>%
  group_by(smoker) %>%
  summarise(
    liczba_osob = n(),
    sredni_koszt = mean(charges),
    mediana_kosztu = median(charges)
  )

print(analiza_palaczy)

# Jak wiek i palenie podbijają oplaty
ggplot(df, aes(x = age, y = charges, color = smoker)) +
  geom_point(alpha = 0.34) +
  theme_classic() +
  theme(panel.grid.major.y = element_line(linetype = "dashed", color = "black"),
        panel.grid.major.x = element_line(linetype = "dashed", color = 'black')) +
  labs(
    title = "Zależność kosztów ubezpieczenia od wieku i palenia tytoniu",
    x = "Wiek",
    y = "Koszt (charges)",
    color = "Czy pali?"
  ) +
  scale_y_continuous(limits = c(0, NA), expand = c(0, 0))
# Modelowanie ekonometryczne

model_pricing <- lm(charges ~ age + bmi + smoker, data = df)
summary(model_pricing)

# Sprawdzenie modelu

par(mfrow = c(2, 2))
plot(model_pricing)
par(mfrow = c(1, 1))

# Predyckja
nowy_klient <- data.frame(
  age = 28,
  bmi = 27,
  smoker = "yes",
  sex = "female"
)

prognoza_skladki <- predict(model_pricing, newdata = nowy_klient)
cat("Sugerowana roczna składka (model liniowy):", round(prognoza_skladki, 2), "USD")

# Leszy model
model_pricing2 <- lm(log(charges) ~ age + bmi * smoker, data = df)

par(mfrow = c(2, 2))
plot(model_pricing2)
par(mfrow = c(1, 1))
summary(model_pricing2)

kolejny <- data.frame(
  age= 60,
  bmi= 20,
  smoker= 'yes'
)
pr <- predict(model_pricing2, kolejny)
cat('wychodzi ze: ',round(exp(pr)), 'usd')
#ggsave("wykres_kosztow.png", width = 8, height = 5)

#Inna metoda rozklad gamma
model_glm <- glm(
  charges ~ age + bmi * smoker, 
  data = df, 
  family = Gamma(link = "log")
)
summary(model_glm)

par(mfrow = c(2, 2))
plot(model_glm)
par(mfrow = c(1, 1))

#predykcja
pr_glm <- predict(model_glm, newdata = kolejny, type = "response")
cat("Prognoza GLM (ostateczna składka):", round(pr_glm), "USD")
