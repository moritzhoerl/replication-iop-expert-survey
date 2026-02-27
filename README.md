# Replication Package

**Thick Concept, Thin Consensus: Normative Judgments in Estimating Inequality of Opportunity**

Author: Moritz Hörl  
Date: 2026

---

## Overview

This repository contains the data and code required to replicate all empirical results reported in the paper. The study compares responsibility beliefs of academic experts in economics, philosophy, and sociology with published estimates from a representative public sample, using a vignette-based survey design.

## Repository Structure

```
├── README.md                 ← This file
├── code/
│   └── 01_main_analysis.R    ← Main analysis script (all tables and tests)
├── data/
│   └── expert_survey.csv     ← Expert vignette survey responses (anonymised)
└── output/
    ├── tables/               ← Generated tables (populated by running code)
    └── figures/              ← Generated figures (populated by running code)
```

## Data

### Expert Survey

The file `data/expert_survey.csv` contains anonymised responses from 150 academics across economics, philosophy, and sociology, collected via an online vignette survey. After applying documented exclusion criteria (see below), the analytical sample comprises 119 complete responses.

### Public Comparison Data

Individual-level data from the representative public survey are not included in this repository as they are owned by the original author. All expert-vs-public comparisons use published summary statistics from:

> André, P. (2024). Shallow Meritocracy. *The Review of Economic Studies*, 92(2), 772–807. https://doi.org/10.1093/restud/rdae040

Specifically, the following published values are used:

| Statistic | Value | N | Source |
|---|---|---|---|
| Proportion redistributing (> 17%) | 54.7% | 887 | André (2024), Table 1 |
| Mean share allocated to disadvantaged | 24.02 | 887 | André (2024), Table 1 |
| SE of mean share | 0.874 | 887 | André (2024), Table 1 |
| Proportion judging circumstances as unfair | 82% | 601 | André (2024), Table 3 |

## Survey Instrument

The vignette survey administered to experts is identical to the instrument used in André (2024). No modifications were made to the vignette texts, question wording, or response options. The only difference is the target population: the original study surveyed a representative sample of the U.S. public, whereas this study surveyed academic experts. The full survey instrument is available at [https://osf.io/xj7vc/](https://osf.io/xj7vc/).

## Variable Definitions

### Demographics

| Variable | Survey Item | Type | Description |
|---|---|---|---|
| `title` | Q1 | Categorical | Academic position: Full professor, Associate professor, Assistant professor/post-doc, Applied research scholar |
| `discipline` | Q3 | Categorical | Primary discipline: Economics, Philosophy, Sociology |

### Vignette 1 (Poverty Scenario) — Primary Analysis

| Variable | Survey Item | Type | Description |
|---|---|---|---|
| `adv_1` | Q12_1_1 | Numeric (0–100) | Percentage of resources allocated to the advantaged individual |
| `disadv_1` | Q12_1_2 | Numeric (0–100) | Percentage of resources allocated to the disadvantaged individual |
| `circ_1` | Q22 | Categorical | Fairness judgment of the circumstances: Fair / Unfair |
| `result_1` | Q23 | Categorical | Fairness judgment of the resulting outcome: Fair / Unfair |

### Vignette 2

| Variable | Survey Item | Type | Description |
|---|---|---|---|
| `adv_2` | Q19_1_1 | Numeric (0–100) | Percentage allocated to advantaged individual |
| `disadv_2` | Q19_1_2 | Numeric (0–100) | Percentage allocated to disadvantaged individual |
| `circ_2` | Q24 | Categorical | Fairness judgment of circumstances |
| `result_2` | Q25 | Categorical | Fairness judgment of result |

### Vignette 3

| Variable | Survey Item | Type | Description |
|---|---|---|---|
| `adv_3` | Q23_1_1 | Numeric (0–100) | Percentage allocated to advantaged individual |
| `disadv_3` | Q23_1_2 | Numeric (0–100) | Percentage allocated to disadvantaged individual |
| `circ_3` | Q26 | Categorical | Fairness judgment of circumstances |
| `result_3` | Q27 | Categorical | Fairness judgment of result |

### Derived Variables (Created by Analysis Script)

| Variable | Type | Description |
|---|---|---|
| `redistributes` | Binary (0/1) | 1 if `disadv_1` > 17 (equal-split benchmark), 0 otherwise |

## Data Cleaning

### Exclusion Criteria

Responses were excluded from the analytical sample if:

- **Both** allocation fields (`adv_1` and `disadv_1`) were missing, **or**
- the `discipline` field was missing.

This removed 31 observations, yielding an analytical sample of N = 119.

### Rescaling of Misformatted Entries

Two respondents entered absolute monetary amounts rather than percentage shares (allocation sums exceeding 110). These were rescaled to percentages using: `rescaled = 100 × (original / sum)`. The script logs both original and rescaled values.

### Multi-Discipline Respondents

Two respondents selected multiple disciplines. These are included in full-sample analyses but excluded from discipline-specific subgroup comparisons.

## Software Requirements

- **R** ≥ 4.0
- Packages: `readr` (≥ 2.1.0), `data.table` (≥ 1.14.0)

```r
install.packages(c("readr", "data.table"))
```

## Instructions to Replicate

1. Clone or download this repository.
2. Open R and set the working directory to the repository root:

```r
setwd("/path/to/replication-package")
```

3. Run the analysis:

```r
source("code/01_main_analysis.R")
```

All results are printed to the console. Tables are saved to `output/tables/`.

## Key Results

| Comparison | Expert | Public | Difference | p (adjusted) |
|---|---|---|---|---|
| Proportion redistributing | 89.1% | 54.7% | +34.4 pp | < 0.001 |
| Mean share to disadvantaged | 35.3% | 24.0% | +11.3 pp | < 0.001 |
| Circumstances judged unfair | 95.8% | 82.0% | +13.8 pp | < 0.001 |

All p-values are Holm–Bonferroni adjusted for three primary comparisons.

## Citation

```
Hörl, M. (2026). Thick Concept, Thin Consensus: Normative Judgments in Estimating
Inequality of Opportunity.
```

## Contact

For questions about the data or code, please contact: moritz.hoerl@wu.ac.at
