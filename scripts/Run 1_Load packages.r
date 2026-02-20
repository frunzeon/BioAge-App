# setup_packages.R
# Pre-flight script to install & check all packages needed for the Shiny Age Prediction app

# List of required packages for the app
required_packages <- c(
  "shiny",
  "readr",
  "dplyr",
  "stringr",
  "glmnet",
  "openxlsx",
  "ggplot2",
  "tibble"
)

# Function to install missing packages
install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    message("Installing missing package: ", pkg)
    install.packages(pkg, dependencies = TRUE)
  } else {
    message("Package already installed: ", pkg)
  }
}

# Install packages if missing
invisible(lapply(required_packages, install_if_missing))

# Load packages and check
loaded_successfully <- sapply(required_packages, function(pkg) {
  suppressWarnings(suppressMessages(require(pkg, character.only = TRUE)))
})

if (all(loaded_successfully)) {
  message("\n✅ All packages loaded successfully.")
  message("🚀 R is ready to run the Shiny app to predict age!")
} else {
  failed_pkgs <- required_packages[!loaded_successfully]
  message("\n❌ Some packages failed to load: ", paste(failed_pkgs, collapse = ", "))
  message("Please check your installation and try again.")
}

