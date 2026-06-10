#' Figure 4 - immunotherapy HR across the CPS spectrum (dot-interval)
#'
#' Restricted-cubic-spline estimate of the OS hazard ratio for CT+ICI vs CT
#' alone, evaluated with \code{rms::contrast} at discrete CPS values and shown as
#' a dot-interval plot (point estimate + 95\% CI at each CPS unit), because CPS
#' is a discrete score rather than a smooth continuum. The caption carries the
#' ANOVA interaction p-values of the spline model.
#'
#' @param object A fitted object from \code{\link{cps_fit}}.
#' @param cps_grid CPS values at which to evaluate the HR (default
#'   \code{seq(2, 100, by = 2)}, evenly spaced).
#' @return A \code{ggplot} object.
#' @export
cps_figure_hr <- function(object = cps_fit(), cps_grid = seq(2, 100, by = 2)) {
  fit <- object$spline
  d <- object$data; dd <- rms::datadist(d); options(datadist = dd)
  lp <- log(cps_grid + 0.1)
  ct <- rms::contrast(fit, list(Immunotherapy = 1, log_cps = lp),
                           list(Immunotherapy = 0, log_cps = lp))
  df <- data.frame(cps = cps_grid, HR = exp(ct$Contrast),
                   lo = exp(ct$Lower), hi = exp(ct$Upper))

  a <- anova(fit)
  gp <- function(pat) { i <- grep(pat, rownames(a), fixed = TRUE)
    if (!length(i)) NA_real_ else as.numeric(a[i[1], ncol(a)]) }
  fp <- function(x) if (is.na(x)) "NA" else if (x < 0.001) "< 0.001" else sprintf("%.3f", x)
  cap <- sprintf(paste0("ANOVA P-values: Overall Interaction = %s | ",
                        "Non-linear Interaction = %s | Total Non-linearity = %s"),
                 fp(gp("All Interactions")), fp(gp("Nonlinear Interaction")),
                 fp(gp("TOTAL NONLINEAR")))

  ggplot2::ggplot(df, ggplot2::aes(x = cps, y = HR)) +
    ggplot2::geom_hline(yintercept = 1, linetype = "dashed", color = "grey45", linewidth = 0.7) +
    ggplot2::geom_errorbar(ggplot2::aes(ymin = lo, ymax = hi), width = 0,
                           color = "#6BAED6", linewidth = 0.6) +
    ggplot2::geom_point(color = "#2171B5", size = 2.2) +
    ggplot2::scale_y_continuous(trans = "log10", breaks = c(0.5, 1.0)) +
    ggplot2::scale_x_continuous(breaks = seq(0, 100, 5)) +
    ggplot2::labs(
      title = "Treatment Effect of Immunotherapy Across CPS Values",
      subtitle = "Hazard Ratios (OS) and 95% Confidence Intervals evaluated at discrete Combined Positive Score units",
      x = "Combined Positive Score (CPS)", y = "Hazard Ratio (95% CI)", caption = cap) +
    ggplot2::theme_minimal(base_size = 13) +
    ggplot2::theme(plot.title = ggplot2::element_text(face = "bold"),
                   plot.subtitle = ggplot2::element_text(color = "grey30"),
                   plot.caption = ggplot2::element_text(hjust = 1, face = "italic", color = "grey40"),
                   axis.title = ggplot2::element_text(face = "bold"),
                   panel.grid.minor = ggplot2::element_blank())
}
