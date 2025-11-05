library(tidyverse)
library(readxl)
library(janitor)

# load
data_path <- "entradas/Planilla Diagnóstico DXT.xlsx"
data_sheet <- readxl::excel_sheets(data_path)[3]

data <- read_xlsx(path = data_path, sheet = data_sheet)

data <- data %>% 
  clean_names()



data[sample(1:length(data),20, replace = F),] %>%
  write_csv("app/data_clean_sample.csv")
