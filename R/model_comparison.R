#' Supplementary Table S4 - model comparison (AIC, BIC, C-index, R2)
#'
#' BIC uses the number of events as the sample size, the usual convention for
#' Cox models.
#'
#' @param object A fitted object from \code{\link{cps_fit}}.
#' @return A data frame comparing the spline, interval and binary models.
#' @export
cps_model_comparison <- function(object = cps_fit()) {
  rows <- rbind(
    Spline   = .cps_stats(object$spline),
    Interval = .cps_stats(object$interval),
    `Binary CPS>=1` = .cps_stats(object$bin1),
    `Binary CPS>=5` = .cps_stats(object$bin5))
  out <- data.frame(
    Model = rownames(rows),
    AIC = round(rows[, "AIC"], 1),
    BIC = round(rows[, "BIC"], 1),
    C_index = round(rows[, "C"], 3),
    Nagelkerke_R2 = round(rows[, "R2"], 3),
    dAIC = round(rows[, "AIC"] - min(rows[, "AIC"]), 1),
    dBIC = round(rows[, "BIC"] - min(rows[, "BIC"]), 1),
    row.names = NULL, check.names = FALSE)
  out[order(out$AIC), ]
}
