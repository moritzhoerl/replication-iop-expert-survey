# Codebook

**Expert Survey on Responsibility Beliefs in the IOp Framework**

---

## Survey Design

The survey presented respondents with vignette scenarios involving two individuals — one advantaged and one disadvantaged — and asked them to make allocation decisions and fairness judgments. Three vignettes were administered; the primary analysis focuses on Vignette 1 (poverty scenario).

The survey instrument is identical to André (2024) and was administered without modification. The original vignette texts, question wording, and response options are available in the supplementary materials of that publication.

## Data File

**Filename:** `expert_survey.csv`  
**Format:** Semicolon-delimited CSV, UTF-8 encoding  
**Raw observations:** 150  
**Analytical sample:** 119 (after exclusions; see below)

---

## Variable Definitions

### Identifiers and Demographics

| Variable | Original | Type | Description |
|---|---|---|---|
| `title` | Q1 | Categorical | Academic position: "Full professor", "Associate professor", "Assistant professor/post-doc", "Applied research scholar" |
| `discipline` | Q3 | Categorical | Primary discipline: "Economics", "Philosophy", "Sociology". Two respondents selected multiple disciplines. |

### Vignette 1: Poverty Scenario

| Variable | Original | Type | Description |
|---|---|---|---|
| `adv_1` | Q12_1_1 | Numeric (0–100) | Percentage of total resources allocated to the advantaged individual |
| `disadv_1` | Q12_1_2 | Numeric (0–100) | Percentage of total resources allocated to the disadvantaged individual |
| `circ_1` | Q22 | Categorical | Fairness judgment of the circumstances: "Fair" or "Unfair" |
| `result_1` | Q23 | Categorical | Fairness judgment of the resulting outcome: "Fair" or "Unfair" |

### Vignette 2

| Variable | Original | Type | Description |
|---|---|---|---|
| `adv_2` | Q19_1_1 | Numeric (0–100) | Percentage allocated to advantaged individual |
| `disadv_2` | Q19_1_2 | Numeric (0–100) | Percentage allocated to disadvantaged individual |
| `circ_2` | Q24 | Categorical | Fairness judgment of circumstances |
| `result_2` | Q25 | Categorical | Fairness judgment of result |

### Vignette 3

| Variable | Original | Type | Description |
|---|---|---|---|
| `adv_3` | Q23_1_1 | Numeric (0–100) | Percentage allocated to advantaged individual |
| `disadv_3` | Q23_1_2 | Numeric (0–100) | Percentage allocated to disadvantaged individual |
| `circ_3` | Q26 | Categorical | Fairness judgment of circumstances |
| `result_3` | Q27 | Categorical | Fairness judgment of result |

---

## Derived Variables (Created in Analysis Script)

| Variable | Type | Description |
|---|---|---|
| `redistributes` | Binary (0/1) | 1 if `disadv_1` > 17 (the equal-split benchmark), 0 otherwise |

---

## Data Cleaning Procedures

### 1. Exclusion of Incomplete Responses

A response is excluded from the analytical sample if:

- **Both** `adv_1` and `disadv_1` are missing (respondent did not complete the allocation task), **or**
- `discipline` is missing (respondent did not report their field).

This criterion removed 31 observations, yielding an analytical sample of N = 119.

### 2. Rescaling of Misformatted Entries

Two respondents entered absolute monetary amounts (e.g., 100,000 and 50,000) rather than percentage shares. These entries were identified by their allocation sum exceeding 110 and were rescaled:

```
rescaled_value = 100 × (original_value / allocation_sum)
```

**Before rescaling:**

| adv_1 | disadv_1 | Sum |
|---|---|---|
| 100,000 | 50,000 | 150,000 |
| 100,000 | 50,000 | 150,000 |

**After rescaling:**

| adv_1 | disadv_1 |
|---|---|
| 66.67 | 33.33 |
| 66.67 | 33.33 |

### 3. Multi-Discipline Respondents

Two respondents selected multiple disciplines ("Economics, Philosophy" and "Economics, Sociology"). These are included in the full-sample analyses but excluded from discipline-specific subgroup analyses, which filter on exact matches to "Economics", "Philosophy", or "Sociology".

---

## External Reference Data

The following published summary statistics are used for expert-vs-public comparisons. Individual-level public data are not included in this repository.

| Source | Statistic | Value | N |
|---|---|---|---|
| Shallow Meritocracy study | Proportion redistributing (> 17%) | 54.7% | 887 |
| Shallow Meritocracy study | Mean share to disadvantaged | 24.02 | 887 |
| Shallow Meritocracy study | SE of mean share | 0.874 | 887 |
| André (2024) | Proportion judging circumstances unfair | 82% | 601 |

---

## Notes

- All analyses use `set.seed(123)` for reproducibility of bootstrap confidence intervals.
- The redistribution threshold of 17% corresponds to an equal split of the vignette's total endowment (1/6 ≈ 16.7%, rounded up to 17%).
- Missing values in qualitative variables (`circ_1`, `result_1`) are excluded pairwise in the relevant analyses.
