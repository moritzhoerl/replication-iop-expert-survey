# Replication Package

**Thick Concept, Thin Consensus: Normative Judgments in Estimating Inequality of Opportunity**

Author: Moritz Hörl  
Date: 2026

---

## Overview

This repository contains the data and code required to replicate all empirical results reported in the paper. The study compares responsibility beliefs of academic experts in economics, philosophy, and sociology with published estimates from a representative public sample, using a vignette-based survey design.

## Repository Structure

```
replication-package/
│
├── README.md                 ← This file
├── CODEBOOK.md               ← Variable definitions and survey instrument details
│
├── code/
│   └── 01_main_analysis.R    ← Main analysis script (all tables and tests)
│
├── data/
│   └── expert_survey.csv     ← Expert vignette survey responses (anonymised)
│
├── output/
│   ├── tables/               ← Generated tables (populated by running code)
│   └── figures/              ← Generated figures (populated by running code)
│
└── docs/
    └── README.md             ← Note on survey instrument (identical to André 2024)
```

## Data

The file `data/expert_survey.csv` contains anonymised responses from 150 academics (economics, philosophy, sociology) collected via an online vignette survey. After applying documented exclusion criteria (see Codebook and analysis script), the analytical sample comprises 119 complete responses.

**Public comparison data:** Individual-level data from the representative public survey ("Shallow Meritocracy") are not included in this repository as they are owned by the original authors. All expert-vs-public comparisons use published summary statistics from:

- [Reference for Shallow Meritocracy study — proportion redistributing: 54.7%, N = 887; mean share to disadvantaged: 24.02, SE = 0.874]
- André (2024) — proportion judging circumstances as unfair: 82%, N = 601

## Survey Instrument

The vignette survey administered to experts is identical to the instrument used in André (2024). No modifications were made to the vignette texts, question wording, or response options. The original survey instrument is available in the supplementary materials of:

> André, P. (2024). [Full citation]. [DOI/URL]

Readers wishing to inspect the exact questionnaire should consult that source.

## Software Requirements
- Required packages:
  - `readr` (≥ 2.1.0)
  - `data.table` (≥ 1.14.0)

Install dependencies:

```r
install.packages(c("readr", "data.table"))
```

## Instructions to Replicate

1. Clone or download this repository.
2. Place the survey data file in `data/` as `expert_survey.csv`.
3. Open R and set the working directory to the repository root:

```r
setwd("/path/to/replication-package")
```

4. Run the analysis:

```r
source("code/01_main_analysis.R")
```

All results will be printed to the console. Tables and figures (if generated) are saved to `output/`.

## Exclusion Criteria

Responses were excluded if:

- Both allocation fields (`adv_1` and `disadv_1`) were missing, **or**
- The discipline field was missing.

Two responses were identified where respondents entered absolute amounts rather than percentage shares (allocation sums exceeding 110). These were rescaled to percentages. Both the original and rescaled values are logged by the script.

See `CODEBOOK.md` for full details.

## Key Results Summary

| Comparison | Expert | Public | Difference | p (adjusted) |
|---|---|---|---|---|
| Proportion redistributing | 89.1% | 54.7% | +34.4 pp | < 0.001 |
| Mean share to disadvantaged | 35.3% | 24.0% | +11.3 pp | < 0.001 |
| Circumstances judged unfair | 95.8% | 82.0% | +13.8 pp | < 0.001 |

All p-values are Holm-Bonferroni adjusted for three primary comparisons.

## Citation

If you use these materials, please cite:

```
Hörl, M. (2025). Thick Concept, Thin Consensus: Normative Judgments in Estimating
Inequality of Opportunity. [Journal], [Volume], [Pages].
```

## License

See `LICENSE` file.

## Contact

For questions about the data or code, please contact: [email address]
