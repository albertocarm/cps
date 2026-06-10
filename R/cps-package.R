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
#'   \item{Die}{Vital status: 1 = death, 0 = censored (alive at last follow-up).}
#'   \item{Immunotherapy}{First-line treatment arm: 0 = chemotherapy alone, 1 = chemotherapy plus anti-PD-1 (CT+ICI).}
#'   \item{cps}{PD-L1 Combined Positive Score (continuous; NA = not tested).}
#'   \item{ECOG}{ECOG performance status: 0 = fully active, 1 = restricted in strenuous activity, 2 = ambulatory and self-caring but unable to work.}
#'   \item{Grade}{Histological grade: 1 = well, 2 = moderately, 3 = poorly differentiated.}
#'   \item{Gender}{Sex: 0 = male, 1 = female.}
#'   \item{age}{Age, years.}
#'   \item{Histology_Lauren_Combined}{Lauren classification: Diffuse or Intestinal (Mixed cases combined).}
#'   \item{signet_ring}{Signet-ring-cell histology: yes = present (any percentage), no = absent.}
#'   \item{burden}{Hepatic tumour burden, estimated percentage of liver parenchyma involved: 0 = no liver involvement, 1 = <25\%, 2 = 25-50\%, 3 = 51-75\%, 4 = >75\%.}
#'   \item{ascites}{Ascites: 0 = none, 1 = mild, 2 = moderate, 3 = severe.}
#'   \item{bone}{Bone metastases: No / Yes.}
#'   \item{num_met}{Number of metastatic sites (organs involved): 1-2 = one or two, >=3 = three or more.}
#'   \item{ratio}{Neutrophil-to-lymphocyte ratio (NLR), continuous.}
#'   \item{oxali}{Oxaliplatin-based backbone (logical).}
#'   \item{ALB}{Basal serum albumin category: 0 = normal (>3.5 g/dL), 1 = 3.0-3.5 g/dL, 2 = <3.0 g/dL.}
#'   \item{year}{Year of treatment initiation.}
#' }
#' @source AGAMENON-SEOM registry (NCT04958720).
"agamenon_cps"
