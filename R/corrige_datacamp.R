# =====================================================
# CorrigeDataCamp 

library(readxl)
library(openxlsx)
library(dplyr)
library(stringr)

# Rutas
entregas_dir <- "Data/entregas"
alumnos_file <- "Data/AlumnosTD25_26.xlsx"
output_dir <- "output"

# Crear output si no existe
if (!dir.exists(output_dir)) {
  dir.create(output_dir)
}

# Buscar TODOS los archivos .txt
ficheros_txt <- list.files(
  path = entregas_dir,
  recursive = TRUE,
  full.names = TRUE,
  pattern = "\\.txt$"
)

# Crear data frame SIEMPRE
evalua_df <- data.frame(
  apellidos = character(),
  puntos = character(),
  NomFile = character(),
  Puntos = character(),
  stringsAsFactors = FALSE
)

if (length(ficheros_txt) > 0) {
  
  datos <- lapply(ficheros_txt, function(f) {
    
    partes <- strsplit(f, .Platform$file.sep)[[1]]
    apellidos <- partes[length(partes) - 1]
    nomfile <- basename(f)
    
    contenido <- readLines(f, warn = FALSE)
    
    puntos <- ifelse(length(contenido) > 0, contenido[1], NA)
    
    data.frame(
      apellidos = apellidos,
      puntos = puntos,
      NomFile = nomfile,
      Puntos = puntos,
      stringsAsFactors = FALSE
    )
  })
  
  evalua_df <- bind_rows(datos)
}

# Ordenar por apellido
if (nrow(evalua_df) > 0) {
  evalua_df <- evalua_df %>% arrange(apellidos)
}

# Guardar NotasRIntermedio.xlsx
write.xlsx(
  evalua_df,
  file = file.path(output_dir, "NotasRIntermedio.xlsx"),
  overwrite = TRUE
)

# Leer alumnos
alumnos <- read_excel(alumnos_file)

# Combinar información
alumnos_notas <- alumnos %>%
  left_join(evalua_df, by = c("Nombre de usuario" = "apellidos"))

# Guardar AlumnosNotas.xlsx
write.xlsx(
  alumnos_notas,
  file = file.path(output_dir, "AlumnosNotas.xlsx"),
  overwrite = TRUE
)

cat("✅ Proceso completo finalizado\n")
cat("Archivos de puntos detectados:", nrow(evalua_df), "\n")