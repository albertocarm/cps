#' cps: Reproducible Continuous PD-L1 CPS Modeling (AGAMENON)
#'
#' Data and helper functions to reproduce the tables and figures of the
#' AGAMENON analysis of PD-L1 CPS and first-line immunotherapy in advanced
#' gastric/gastroesophageal junction adenocarcinoma.
#'
#' Main functions: \code{\link{cps_prepare}}, \code{\link{cps_table1}},
#' \code{\link{cps_distribution}}, \code{\link{cps_fit}},
#' \code{\link{cps_table2}}, \code{\link{cps_model_comparison}},
#' \code{\link{cps_figure_hr}}.
#'
#' @keywords internal
#' @importFrom survival Surv
#' @importFrom Hmisc aregImpute fit.mult.impute
#' @importFrom rms cph rcs datadist contrast
#' @importFrom stats anova as.formula reformulate complete.cases setNames AIC
"_PACKAGE"

# variables referenced in ggplot aes() within cps_figure_hr()
if (getRversion() >= "2.15.1") utils::globalVariables(c("cps", "HR", "lo", "hi"))

#' AGAMENON CPS dataset (de-identified)
#'
#' Patient-level data of 1040 patients with advanced HER2-negative
#' gastric/gastroesophageal junction adenocarcinoma treated with first-line
#' platinum-fluoropyrimidine chemotherapy with or without anti-PD-1
#' immunotherapy. Only the variables required to reproduce the manuscript are
#' included; the patient identifier and other non-analysis fields have been
#' removed so individuals are not traceable. Derived columns (\code{log_cps},
#' CPS categories, treatment arm) are rebuilt by \code{\link{cps_prepare}}.
#'
#' @format A data frame with 1040 rows and 18 variables:
#' \describe{
#'   \item{SGm}{Overall survival, months.}
#'   \item{Die}{Death indicator (1 = death, 0 = censored).}
#'   \item{Immunotherapy}{Treatment: 1 = chemo + anti-PD-1 (CT+ICI), 0 = chemo alone.}
#'   \item{cps}{PD-L1 Combined Positive Score (continuous; NA = not tested).}
#'   \item{ECOG}{ECOG performance status.}
#'   \item{Grade}{Histological grade.}
#'   \item{Gender}{Sex.}
#'   \item{age}{Age, years.}
#'   \item{Histology_Lauren_Combined}{Lauren histology (Diffuse / Intestinal).}
#'   \item{signet_ring}{Signet-ring-cell histology (yes / no).}
#'   \item{burden}{Hepatic tumour burden category (0 = no liver involvement ... 4).}
#'   \item{ascites}{Ascites grade (0-3).}
#'   \item{bone}{Bone metastases indicator.}
#'   \item{num_met}{Number of metastatic sites (1-2 / >=3).}
#'   \item{ratio}{Neutrophil-to-lymphocyte ratio (NLR).}
#'   \item{oxali}{Oxaliplatin-based backbone (logical).}
#'   \item{ALB}{Serum albumin (auxiliary variable for multiple imputation).}
#'   \item{year}{Year of treatment initiation.}
#' }
#' @source AGAMENON-SEOM registry (NCT04958720).
"agamenon_cps"
