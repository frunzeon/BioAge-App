# ﻿**Shiny App**

# **Model: Biological Age Prediction of Honey Bees**

## 1. **Overview**

This repository contains a Shiny application for predicting the **biological immune age (Immune Aging Index, IAI, in day-equivalent units)** of honey bees using quantitative PCR (qPCR) Ct values and a pre-trained Elastic Net Regression (ENR) model.

The application:

- Normalizes Ct values using *Actin* as reference gene
- Applies a fixed Elastic Net model
- Generates biological age predictions
- Produces publication-ready plots
- Exports formatted Excel results

The predictive model is hardcoded to ensure reproducibility.

## 2. **Repository Structure**

**Main**/

- metadata.csv

- LICENSE

- README.md

**Scripts**/

- Run1\_Load packages.r

- Run2\_MODEL.r

**data\_example**/

- ct\_values\_raw\_X.txt (X=A, B, C, D, E)

**example-results**/

- Predicted\_Age\_ResultsX.xlsx (X = A, B, C, D, E)

- Predicted\_Age\_PlotX.png (X = A, B, C, D, E)

## 3. **Scientific Basis**

Biological age is estimated using immune-related gene expression:

- *Dome*
- *Relish*
- *SOD1*
- *Apid1*

Normalization: ΔCt=Ct<sub>target</sub>−Ct<sub>Actin​</sub> 

The trained model uses Elastic Net Regression (glmnet) with fixed parameters.

## 4. **System Requirements**
- R ≥ 4.2.0 (recommended 4.3+)
- RStudio (recommended)

**Required packages will be installed automatically when running Run1_Load packages.r**

install.packages(c(

- "shiny",
- "ggplot2",
- "readr",
- "openxlsx",
- "glmnet",
- "dplyr",
- "stringr",
- "tibble"
))

## 5. **How to Run the App**

**RStudio**
| Step | Action |
|------|--------|
| A | Open the repository folder in RStudio |
| B | Open file: `Run1_Load packages.r` |
| C | Click **Run** |
| D | Open file: `Run2_MODEL.r` |
| E | Click **Run App** |

**Input File Format**

The input file must be:

- .txt
- Tab-separated
- UTF-8 encoded
- One row per bee sample

**Required Columns**

| Sampleage | Ct_Actin_SOD1 | Ct_SOD1 | Ct_Actin_Dome_Apid1 | Ct_Dome | Ct_Apid1 | Ct_Actin_Relish | Ct_Relish |
|------------|---------------|---------|----------------------|---------|----------|-----------------|------------|

| Column Name | Description |
|-------------|------------|
| Sampleage | Sample developmental stage |
| Ct_Actin_SOD1 | Reference Ct for SOD1 normalization |
| Ct_SOD1 | Target Ct value |
| Ct_Actin_Dome_Apid1 | Reference Ct for Dome and Apid1 |
| Ct_Dome | Target Ct value |
| Ct_Apid1 | Target Ct value |
| Ct_Actin_Relish | Reference Ct for Relish |
| Ct_Relish | Target Ct value |

If any required column is missing, the application will return an error.

## 6. **Output**

### PNG Plot
- Predicted biological age (Immune Aging Index, in day-equivalent) by group

### Excel File (.xlsx)
- Predicted biological age (Immune Aging Index) values (day-equivalent)
- Normalized expression values
The app generates:

All outputs are reproducible given identical input and R environment.

## 7. **Reproducibility**

This repository includes:

- Fixed ENR model coefficients
- Defined normalization procedure
- Deterministic prediction workflow

Predictions are reproducible under identical:

- Input data
- R version
- Package versions

For model training details, refer to the associated manuscript.

## 8. **Metadata**

See metadata.csv for:

- Variable definitions
- Gene descriptions
- Normalization details
## 9. **Limitations**
- Designed for *Apis mellifera*
- Trained on defined developmental stages
- Extrapolation beyond training range may reduce accuracy
## 10. **Intellectual Property Notice**

The biological age prediction methodology implemented in this repository is subject to a filed patent application.

While the source code is released under the MIT License to support scientific transparency and reproducibility, commercial exploitation of the patented method may require a separate licensing agreement with the rights holder.

For commercial inquiries, please contact:

Prof. Hyung-Wook Kwon\
Department of Life Sciences\
Incheon National University\
Email: hwkwon@inu.ac.kr
























