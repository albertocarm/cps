#' CPS distribution (binary thresholds and non-overlapping intervals)
#'
#' @param data A data frame like \code{agamenon_cps}.
#' @return A list with two data frames: \code{binary} (>=1, >=5, >=10) and
#'   \code{intervals} (<1, 1-4, 5-9, >=10), both over evaluable CPS.
#' @export
cps_distribution <- function(data = cps::agamenon_cps) {
  d <- as.data.frame(data)
  ev <- d$cps[!is.na(d$cps)]; n <- length(ev)
  binary <- data.frame(
    threshold = c(">=1", ">=5", ">=10"),
    n = c(sum(ev >= 1), sum(ev >= 5), sum(ev >= 10)),
    pct = round(100 * c(mean(ev >= 1), mean(ev >= 5), mean(ev >= 10)), 1))
  ic <- cut(ev, c(-Inf, 1, 5, 10, Inf), right = FALSE,
            labels = c("<1", "1-4", "5-9", ">=10"))
  intervals <- data.frame(interval = levels(ic),
                          n = as.integer(table(ic)),
                          pct = round(100 * as.numeric(table(ic)) / n, 1))
  list(n_evaluable = n, binary = binary, intervals = intervals)
}
