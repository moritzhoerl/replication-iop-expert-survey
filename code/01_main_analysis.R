###############################################################################
# Replication: Expert Survey on Responsibility Beliefs (IOp Framework)
#
# Description:  This script replicates the main analyses of the expert vignette
#               study comparing responsibility beliefs of academics in
#               economics, philosophy, and sociology with published estimates
#               from a representative public sample ("Shallow Meritocracy").
#
# Data:         Replication shallow meritocracy_expert_sample.csv
#
# Author:      Moritz Hörl
# Date:        27.02.2027
# Software:     R >= 4.0
###############################################################################

# --- 0. Setup ----------------------------------------------------------------

library(readr)
library(data.table)

# For reproducibility
set.seed(123)

# --- 1. Load and prepare data ------------------------------------------------

raw <- read_delim(
  file.path("..", "data", "expert_survey.csv"),
  delim = ";",
  col_types = cols(.default = "c"),
  trim_ws = TRUE
)
setDT(raw)

# Select and rename relevant columns
raw <- raw[, .(Q1, Q3, Q12_1_1, Q12_1_2, Q22, Q23,
               Q19_1_1, Q19_1_2, Q24, Q25,
               Q23_1_1, Q23_1_2, Q26, Q27)]

setnames(raw,
         old = c("Q1", "Q3", "Q12_1_1", "Q12_1_2", "Q22", "Q23",
                 "Q19_1_1", "Q19_1_2", "Q24", "Q25",
                 "Q23_1_1", "Q23_1_2", "Q26", "Q27"),
         new = c("title", "discipline",
                 "adv_1", "disadv_1", "circ_1", "result_1",
                 "adv_2", "disadv_2", "circ_2", "result_2",
                 "adv_3", "disadv_3", "circ_3", "result_3"))

cat("Raw dataset rows:", nrow(raw), "\n")

# --- 2. Poverty vignette: select and clean ------------------------------------

# Extract columns for the poverty vignette (vignette 1)
vignette1 <- raw[, .(title, discipline, adv_1, disadv_1, circ_1, result_1)]

# Convert allocation variables to numeric for validation
vignette1[, adv_1  := as.numeric(adv_1)]
vignette1[, disadv_1 := as.numeric(disadv_1)]

# --- 2a. Drop incomplete responses -------------------------------------------
# Criterion: a response is incomplete if BOTH allocation fields are missing
#            OR if the discipline field is missing.

n_before <- nrow(vignette1)

vignette1 <- vignette1[!(is.na(adv_1) & is.na(disadv_1)) & !is.na(discipline)]

n_after <- nrow(vignette1)
cat("Dropped", n_before - n_after,
    "incomplete responses (missing allocations or discipline).",
    "Remaining N =", n_after, "\n")

# --- 2b. Correct rescaling errors --------------------------------------------
# Some respondents entered absolute amounts (summing to ~100 in total value)
# rather than percentage shares. These are identified by adv_1 + disadv_1
# summing to a value far above 100. We rescale them to percentages.
#
# Example: a respondent entering 65 and 35 (summing to 100) is fine;
#          a respondent entering 650 and 350 (summing to 1000) entered full
#          sums rather than ratios and must be rescaled.

vignette1[, allocation_sum := adv_1 + disadv_1]

# Flag rows where the sum is implausibly large (> 110, allowing small rounding)
rescale_threshold <- 110
rescale_rows <- which(vignette1$allocation_sum > rescale_threshold)

if (length(rescale_rows) > 0) {
  cat("Rescaling", length(rescale_rows),
      "response(s) where allocation sum exceeded", rescale_threshold,
      "(likely entered as absolute amounts rather than percentages):\n")
  print(vignette1[rescale_rows, .(adv_1, disadv_1, allocation_sum)])

  vignette1[rescale_rows, `:=`(
    adv_1    = round(100 * adv_1 / allocation_sum, 2),
    disadv_1 = round(100 * disadv_1 / allocation_sum, 2)
  )]
  cat("After rescaling:\n")
  print(vignette1[rescale_rows, .(adv_1, disadv_1)])
}

# Clean up helper column
vignette1[, allocation_sum := NULL]

# --- 3. Descriptive statistics ------------------------------------------------

cat("\n=== Full Sample Descriptives ===\n")
cat("N =", nrow(vignette1), "\n")
cat("Mean share allocated to disadvantaged (disadv_1):",
    round(mean(vignette1$disadv_1, na.rm = TRUE), 2), "\n")
cat("SD:",
    round(sd(vignette1$disadv_1, na.rm = TRUE), 2), "\n")
cat("Median:",
    round(median(vignette1$disadv_1, na.rm = TRUE), 2), "\n")
cat("Range:", range(vignette1$disadv_1, na.rm = TRUE), "\n")

# 95% confidence interval for the mean (bootstrap)
boot_means <- replicate(10000, {
  s <- sample(vignette1$disadv_1, replace = TRUE)
  mean(s, na.rm = TRUE)
})
ci_full <- quantile(boot_means, c(0.025, 0.975))
cat("95% Bootstrap CI for mean:", round(ci_full, 2), "\n")

# --- 3a. Descriptives by discipline -------------------------------------------

disciplines <- c("Philosophy", "Economics", "Sociology")
desc_by_disc <- vignette1[discipline %in% disciplines,
                          .(n     = .N,
                            mean  = round(mean(disadv_1, na.rm = TRUE), 2),
                            sd    = round(sd(disadv_1, na.rm = TRUE), 2),
                            median = round(median(disadv_1, na.rm = TRUE), 2)),
                          by = discipline]
cat("\n=== Descriptives by Discipline ===\n")
print(desc_by_disc)

# --- 4. Main analysis: proportion redistributing -----------------------------

# A respondent is classified as "redistributing" if they allocate more than
# the equal-split benchmark (17%) to the disadvantaged individual.
REDISTRIBUTION_THRESHOLD <- 17

vignette1[, redistributes := as.integer(disadv_1 > REDISTRIBUTION_THRESHOLD)]

# --- 4a. Proportions with exact binomial confidence intervals -----------------

compute_proportion_ci <- function(data, label = "Sample") {
  n_total <- nrow(data)
  n_redist <- sum(data$redistributes, na.rm = TRUE)
  bt <- binom.test(n_redist, n_total)
  data.table(
    sample     = label,
    n          = n_total,
    n_redist   = n_redist,
    proportion = round(bt$estimate, 3),
    ci_lower   = round(bt$conf.int[1], 3),
    ci_upper   = round(bt$conf.int[2], 3)
  )
}

prop_results <- rbindlist(list(
  compute_proportion_ci(vignette1, "Full expert sample"),
  compute_proportion_ci(vignette1[discipline == "Philosophy"], "Philosophy"),
  compute_proportion_ci(vignette1[discipline == "Economics"], "Economics"),
  compute_proportion_ci(vignette1[discipline == "Sociology"], "Sociology")
))

cat("\n=== Proportion Redistributing (> 17% to disadvantaged) ===\n")
print(prop_results)

# --- 5. Comparison with public sample (Shallow Meritocracy) -------------------
#
# Reference values from the published representative survey:
#   - Proportion redistributing: p = 0.547, N = 887
#   - Mean share to disadvantaged: mean = 24.02, SE = 0.874, N = 887
#
# NOTE: Individual-level public data are not available for this replication.
#       All comparisons therefore use summary-statistic-based tests.
#       This is a limitation; results should be interpreted accordingly.

public_p    <- 0.547
public_n    <- 887
public_mean <- 24.02
public_se   <- 0.874

# --- 5a. Test: proportion redistributing (experts vs. public) ----------------
# Two-sample test of proportions (with continuity correction)

expert_redist_n <- sum(vignette1$redistributes, na.rm = TRUE)
expert_total_n  <- nrow(vignette1)

# Use integer counts for the test
prop_test <- prop.test(
  x = c(expert_redist_n, round(public_p * public_n)),
  n = c(expert_total_n, public_n),
  correct = TRUE
)

cat("\n=== Experts vs. Public: Proportion Redistributing ===\n")
cat("Expert proportion:", round(expert_redist_n / expert_total_n, 3), "\n")
cat("Public proportion:", public_p, "\n")
cat("Chi-squared =", round(prop_test$statistic, 3),
    ", p-value =", format.pval(prop_test$p.value, digits = 4), "\n")

# Effect size: difference in proportions with 95% CI
p_expert <- expert_redist_n / expert_total_n
diff_p <- p_expert - public_p
se_diff <- sqrt((p_expert * (1 - p_expert)) / expert_total_n +
                (public_p * (1 - public_p)) / public_n)
ci_diff_p <- c(diff_p - 1.96 * se_diff, diff_p + 1.96 * se_diff)
cat("Difference (expert - public):", round(diff_p, 3),
    "  95% CI:", round(ci_diff_p, 3), "\n")

# Also report Fisher's exact test for robustness (requires integer counts)
fisher_table <- matrix(
  c(expert_redist_n,
    round(public_p * public_n),
    expert_total_n - expert_redist_n,
    public_n - round(public_p * public_n)),
  nrow = 2
)
fisher_result <- fisher.test(fisher_table)
cat("Fisher's exact test p-value:", format.pval(fisher_result$p.value, digits = 4), "\n")

# --- 5b. Test: mean compensation share (experts vs. public) ------------------
# Two-sample z-test using summary statistics (Welch-type approximation).
# This is the appropriate test when only summary statistics from the
# comparison sample are available.

expert_mean <- mean(vignette1$disadv_1, na.rm = TRUE)
expert_sd   <- sd(vignette1$disadv_1, na.rm = TRUE)
expert_n    <- nrow(vignette1)

# Reconstruct public SD from reported SE
public_sd <- public_se * sqrt(public_n)

# Welch two-sample z-test
z_stat <- (expert_mean - public_mean) /
  sqrt((expert_sd^2 / expert_n) + (public_sd^2 / public_n))
z_pvalue <- 2 * pnorm(-abs(z_stat))

# Cohen's d (pooled SD)
pooled_sd <- sqrt(((expert_n - 1) * expert_sd^2 + (public_n - 1) * public_sd^2) /
                    (expert_n + public_n - 2))
cohens_d <- (expert_mean - public_mean) / pooled_sd

# 95% CI for the mean difference
se_meandiff <- sqrt((expert_sd^2 / expert_n) + (public_sd^2 / public_n))
diff_means <- expert_mean - public_mean
ci_meandiff <- c(diff_means - 1.96 * se_meandiff, diff_means + 1.96 * se_meandiff)

cat("\n=== Experts vs. Public: Mean Compensation Share ===\n")
cat("Expert mean:", round(expert_mean, 2), " (SD =", round(expert_sd, 2), ")\n")
cat("Public mean:", public_mean, " (SD =", round(public_sd, 2), ")\n")
cat("Difference:", round(diff_means, 2),
    "  95% CI:", round(ci_meandiff, 2), "\n")
cat("z =", round(z_stat, 3), ", p =", format.pval(z_pvalue, digits = 4), "\n")
cat("Cohen's d:", round(cohens_d, 3), "\n")

# --- 6. Qualitative responses: fairness judgments -----------------------------

compute_percentage_ci <- function(data, column, value, label = "") {
  count <- sum(data[[column]] == value, na.rm = TRUE)
  total <- sum(!is.na(data[[column]]))
  bt <- binom.test(count, total)
  data.table(
    sample     = label,
    category   = value,
    n          = total,
    count      = count,
    percentage = round(bt$estimate * 100, 1),
    ci_lower   = round(bt$conf.int[1] * 100, 1),
    ci_upper   = round(bt$conf.int[2] * 100, 1)
  )
}

cat("\n=== Qualitative: Circumstances judged 'Unfair' ===\n")
circ_results <- rbindlist(list(
  compute_percentage_ci(vignette1, "circ_1", "Unfair", "Full sample"),
  compute_percentage_ci(vignette1[discipline == "Philosophy"], "circ_1", "Unfair", "Philosophy"),
  compute_percentage_ci(vignette1[discipline == "Economics"], "circ_1", "Unfair", "Economics"),
  compute_percentage_ci(vignette1[discipline == "Sociology"], "circ_1", "Unfair", "Sociology")
))
print(circ_results)

cat("\n=== Qualitative: Result judged 'Fair' ===\n")
result_results <- rbindlist(list(
  compute_percentage_ci(vignette1, "result_1", "Fair", "Full sample"),
  compute_percentage_ci(vignette1[discipline == "Philosophy"], "result_1", "Fair", "Philosophy"),
  compute_percentage_ci(vignette1[discipline == "Economics"], "result_1", "Fair", "Economics"),
  compute_percentage_ci(vignette1[discipline == "Sociology"], "result_1", "Fair", "Sociology")
))
print(result_results)

# --- 6a. Comparison with Andre (2024) public fairness data -------------------

expert_unfair_n <- sum(vignette1$circ_1 == "Unfair", na.rm = TRUE)
expert_circ_n   <- sum(!is.na(vignette1$circ_1))

andre_p <- 0.82
andre_n <- 601

prop_test_andre <- prop.test(
  x = c(expert_unfair_n, round(andre_p * andre_n)),
  n = c(expert_circ_n, andre_n),
  correct = TRUE
)

p_expert_circ <- expert_unfair_n / expert_circ_n
diff_andre <- p_expert_circ - andre_p
se_andre <- sqrt((p_expert_circ * (1 - p_expert_circ)) / expert_circ_n +
                 (andre_p * (1 - andre_p)) / andre_n)
ci_andre <- c(diff_andre - 1.96 * se_andre, diff_andre + 1.96 * se_andre)

cat("\n=== Experts vs. Andre (2024) Public: Circumstances 'Unfair' ===\n")
cat("Expert proportion:", round(p_expert_circ, 3), "\n")
cat("Public proportion (Andre 2024):", andre_p, "\n")
cat("Difference:", round(diff_andre, 3),
    "  95% CI:", round(ci_andre, 3), "\n")
cat("Chi-squared =", round(prop_test_andre$statistic, 3),
    ", p =", format.pval(prop_test_andre$p.value, digits = 4), "\n")

# --- 7. Between-discipline comparisons ---------------------------------------

cat("\n=== Kruskal-Wallis: Compensation share across disciplines ===\n")
kw_test <- kruskal.test(disadv_1 ~ discipline,
                        data = vignette1[discipline %in% disciplines])
cat("H =", round(kw_test$statistic, 3),
    ", df =", kw_test$parameter,
    ", p =", format.pval(kw_test$p.value, digits = 4), "\n")

# Pairwise comparisons (Wilcoxon) with Holm correction for multiple testing
if (kw_test$p.value < 0.05) {
  cat("\nPairwise Wilcoxon tests (Holm-adjusted):\n")
  pw <- pairwise.wilcox.test(
    vignette1[discipline %in% disciplines]$disadv_1,
    vignette1[discipline %in% disciplines]$discipline,
    p.adjust.method = "holm"
  )
  print(pw)
}

# --- 8. Multiple testing correction (summary) ---------------------------------
#
# The primary comparisons are:
#   (1) Experts vs. public: proportion redistributing
#   (2) Experts vs. public: mean compensation share
#   (3) Experts vs. Andre (2024): fairness judgment
#
# We apply Holm-Bonferroni correction to these three primary tests.

primary_pvalues <- c(
  prop_redist = prop_test$p.value,
  mean_comp   = z_pvalue,
  fairness    = prop_test_andre$p.value
)

adjusted_pvalues <- p.adjust(primary_pvalues, method = "holm")

cat("\n=== Multiple Testing Correction (Holm-Bonferroni) ===\n")
cat("Primary tests and adjusted p-values:\n")
for (i in seq_along(primary_pvalues)) {
  cat(sprintf("  %-15s  raw p = %-10s  adjusted p = %s\n",
              names(primary_pvalues)[i],
              format.pval(primary_pvalues[i], digits = 4),
              format.pval(adjusted_pvalues[i], digits = 4)))
}

# --- 9. Sample composition ----------------------------------------------------

cat("\n=== Sample Composition: Job Titles ===\n")
job_counts  <- table(vignette1$title)
job_percent <- round(prop.table(job_counts) * 100, 1)

job_table <- data.table(
  title      = names(job_counts),
  n          = as.integer(job_counts),
  percentage = as.numeric(job_percent)
)
job_table <- job_table[order(-n)]
print(job_table)

cat("\n=== Sample Composition: Disciplines ===\n")
disc_counts  <- table(vignette1$discipline)
disc_percent <- round(prop.table(disc_counts) * 100, 1)

disc_table <- data.table(
  discipline = names(disc_counts),
  n          = as.integer(disc_counts),
  percentage = as.numeric(disc_percent)
)
disc_table <- disc_table[order(-n)]
print(disc_table)

# --- 10. Export results tables -------------------------------------------------

output_dir <- file.path("..", "output", "tables")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

# Table 1: Descriptives by discipline
fwrite(desc_by_disc, file.path(output_dir, "table1_descriptives_by_discipline.csv"))

# Table 2: Proportion redistributing with CIs
fwrite(prop_results, file.path(output_dir, "table2_proportion_redistributing.csv"))

# Table 3: Expert-vs-public comparisons
comparison_table <- data.table(
  comparison = c(
    "Proportion redistributing",
    "Mean compensation share",
    "Circumstances judged unfair"
  ),
  expert = c(
    round(p_expert, 3),
    round(expert_mean, 2),
    round(p_expert_circ, 3)
  ),
  public = c(public_p, public_mean, andre_p),
  difference = c(
    round(diff_p, 3),
    round(diff_means, 2),
    round(diff_andre, 3)
  ),
  ci_lower = c(
    round(ci_diff_p[1], 3),
    round(ci_meandiff[1], 2),
    round(ci_andre[1], 3)
  ),
  ci_upper = c(
    round(ci_diff_p[2], 3),
    round(ci_meandiff[2], 2),
    round(ci_andre[2], 3)
  ),
  p_raw = c(
    prop_test$p.value,
    z_pvalue,
    prop_test_andre$p.value
  ),
  p_adjusted = adjusted_pvalues
)
fwrite(comparison_table, file.path(output_dir, "table3_expert_vs_public.csv"))

# Table 4: Fairness judgments by discipline
fwrite(circ_results, file.path(output_dir, "table4_circumstances_unfair.csv"))
fwrite(result_results, file.path(output_dir, "table5_result_fair.csv"))

# Table 6: Sample composition
fwrite(job_table, file.path(output_dir, "table6_job_titles.csv"))
fwrite(disc_table, file.path(output_dir, "table7_disciplines.csv"))

cat("\nTables saved to:", normalizePath(output_dir), "\n")

# --- End of script ------------------------------------------------------------
cat("\n=== Replication complete ===\n")
