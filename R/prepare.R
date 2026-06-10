#' Prepare/recode the CPS dataset for analysis
#'
#' Builds the factors and CPS parameterizations used by all other functions:
#' treatment arm, hepatic burden (level 0 = "No liver involvement"; 4 collapsed
#' into >50\%), non-overlapping CPS intervals (<1, 1-4, 5-9, >=10, Unknown) and
#' binary thresholds (>=1, >=5, >=10, each keeping an explicit "Unknown" level),
#' and log_cps = log(cps + 0.1).
#'
#' @param data A data frame like \code{agamenon_cps}.
#' @return The data frame with added/standardized factor columns.
#' @export
cps_prepare <- function(data = cps::agamenon_cps) {
  d <- as.data.frame(data)
  d$arm     <- factor(d$Immunotherapy, levels = c(0,1), labels = c("CT alone","CT + ICI"))
  d$ECOG    <- factor(d$ECOG)
  d$Grade   <- factor(d$Grade)
  d$Gender  <- factor(d$Gender)
  d$num_met <- factor(d$num_met)
  d$oxali   <- factor(d$oxali)
  b <- suppressWarnings(as.numeric(as.character(d$burden))); b[b == 4] <- 3
  d$burden <- factor(b, levels = c(0,1,2,3),
                     labels = c("No liver involvement","<25%","25-50%",">50%"))
  if (is.null(d$log_cps)) d$log_cps <- log(d$cps + 0.1)
  d$cps_cat <- cut(d$cps, c(-Inf,1,5,10,Inf), right = FALSE,
                   labels = c("CPS<1","CPS1-4","CPS5-9","CPS>=10"))
  d$cps_cat <- factor(ifelse(is.na(d$cps_cat), "Unknown", as.character(d$cps_cat)),
                      levels = c("CPS<1","CPS1-4","CPS5-9","CPS>=10","Unknown"))
  mkbin <- function(x,k) factor(ifelse(is.na(x),"Unknown",ifelse(x>=k,"pos","neg")),
                                levels = c("neg","pos","Unknown"))
  d$cps1 <- mkbin(d$cps,1); d$cps5 <- mkbin(d$cps,5); d$cps10 <- mkbin(d$cps,10)
  d
}

# Adjustment covariates of the primary CPS-by-immunotherapy interaction model
# (manuscript Table 2 / Suppl. Table S4 / Figure 4): ECOG, Lauren histology,
# tumor grade, number of metastatic sites, hepatic burden, age and NLR
# (restricted cubic splines), and year of treatment initiation.
.cps_covs <- function()
  "ECOG + Histology_Lauren_Combined + Grade + num_met + burden + rcs(age,3) + rcs(ratio,3) + year"
