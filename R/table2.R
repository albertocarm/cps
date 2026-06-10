#' Table 2 - immunotherapy HR by CPS subgroup (with EPAR/Leone references)
#'
#' Reproduces manuscript Table 2. Cumulative thresholds (>=1, >=5, >=10) are the
#' immunotherapy-vs-chemotherapy hazard ratios within the CPS-positive group of
#' the corresponding binary model; non-overlapping intervals (1-4, 5-9) come from
#' the categorical \code{Immunotherapy * cps_cat} model. All estimates share the
#' primary adjustment set (see \code{\link{cps_fit}}).
#'
#' @param object A fitted object from \code{\link{cps_fit}}.
#' @return A data frame mirroring Table 2 of the manuscript.
#' @export
cps_table2 <- function(object = cps_fit()) {
  d <- object$data
  dd <- rms::datadist(d); options(datadist = dd)
  obs <- d[!is.na(d$cps), ]
  nf <- function(cond) sprintf("%d (%d / %d)", sum(cond),
                               sum(cond & obs$Immunotherapy == 0),
                               sum(cond & obs$Immunotherapy == 1))
  fmt <- function(v) sprintf("%.2f (%.2f-%.2f)", v["hr"], v["lo"], v["hi"])
  pf  <- function(v) ifelse(v["p"] < 0.001, "<0.001", sprintf("%.3f", v["p"]))

  h_ge1  <- .cps_hr(object$bin1,     "cps1",    "pos")
  h_14   <- .cps_hr(object$interval, "cps_cat", "CPS1-4")
  h_ge5  <- .cps_hr(object$bin5,     "cps5",    "pos")
  h_59   <- .cps_hr(object$interval, "cps_cat", "CPS5-9")
  h_ge10 <- .cps_hr(object$bin10,    "cps10",   "pos")

  epar <- c("-","-",
            "0.70 (0.60-0.81) Nivo / 0.70 (0.60-0.82) Pembro",
            "0.92 (0.66-1.28) Nivo / 0.94 (0.71-1.25) Pembro",
            "0.65 (0.55-0.78) Nivo / 0.65 (0.53-0.79) Pembro")
  leone <- c("0.840 (0.753-0.937) p=0.002",
             "0.868 (0.772-0.976) p=0.018","-","0.867 (0.702-1.069) p=0.181","-")

  data.frame(
    CPS_subgroup = c(">=1", "1-4", ">=5", "5-9", ">=10"),
    N_CT_ICI = c(nf(obs$cps>=1), nf(obs$cps>=1 & obs$cps<5),
                 nf(obs$cps>=5), nf(obs$cps>=5 & obs$cps<10), nf(obs$cps>=10)),
    HR_95CI = c(fmt(h_ge1), fmt(h_14), fmt(h_ge5), fmt(h_59), fmt(h_ge10)),
    p_value = c(pf(h_ge1), pf(h_14), pf(h_ge5), pf(h_59), pf(h_ge10)),
    EPAR = epar, Leone = leone,
    stringsAsFactors = FALSE, check.names = FALSE)
}
