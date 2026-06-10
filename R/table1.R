#' Table 1 - baseline characteristics by treatment arm
#'
#' @param data A data frame like \code{agamenon_cps}.
#' @return A \code{gtsummary} table.
#' @export
cps_table1 <- function(data = cps::agamenon_cps) {
  d <- cps_prepare(data)
  vars <- c("arm", "age", "Gender", "ECOG", "Histology_Lauren_Combined", "Grade",
            "signet_ring", "burden", "num_met", "bone", "ascites", "oxali", "cps", "cps_cat")
  vars <- intersect(vars, names(d))
  gtsummary::tbl_summary(
    d[, vars], by = "arm", missing = "ifany",
    statistic = list(gtsummary::all_continuous() ~ "{median} ({p25}, {p75})")
  )
}
