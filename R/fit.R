#' Fit the CPS-by-immunotherapy models (multiple imputation)
#'
#' Reproduces the AGAMENON primary analysis (manuscript Table 2 / Supplementary
#' Table S4 / Figure 4). A single multiply imputed dataset (\code{aregImpute},
#' m = 10, \code{nk = 0}, seed 123) is used to fit one Cox model per CPS
#' parameterization, all sharing the same adjustment set
#' (\code{.cps_covs}: ECOG, Lauren histology, tumor grade, number of
#' metastatic sites, hepatic burden, age and NLR as restricted cubic splines,
#' and year of treatment initiation). Missing CPS is carried as an explicit
#' \dQuote{Unknown} level for the categorical/binary parameterizations and is
#' imputed (on the log scale) only for the continuous spline. Subgroup hazard
#' ratios are obtained with \code{rms::contrast}.
#'
#' @param data A data frame like \code{agamenon_cps}.
#' @param m Number of imputations (default 10).
#' @param seed Random seed (default 123).
#' @return A list with the fitted models and the interaction p-values.
#' @export
cps_fit <- function(data = cps::agamenon_cps, m = 10, seed = 123) {
  d <- as.data.frame(data)
  d$ECOG  <- factor(d$ECOG)
  d$Grade <- factor(d$Grade)
  b <- suppressWarnings(as.numeric(as.character(d$burden))); b[b == 4] <- 3
  d$burden <- factor(b, levels = c(0,1,2,3),
                     labels = c("No liver involvement","<25%","25-50%",">50%"))
  d$year <- droplevels(factor(d$year))
  if (is.null(d$log_cps)) d$log_cps <- log(d$cps + 0.1)
  mkbin <- function(x,k) factor(ifelse(is.na(x),"Unknown",ifelse(x>=k,"pos","neg")),
                                levels = c("neg","pos","Unknown"))
  d$cps1 <- mkbin(d$cps,1); d$cps5 <- mkbin(d$cps,5); d$cps10 <- mkbin(d$cps,10)
  d$cps_cat <- cut(d$cps, c(-Inf,1,5,10,Inf), right = FALSE,
                   labels = c("CPS<1","CPS1-4","CPS5-9","CPS>=10"))
  d$cps_cat <- factor(ifelse(is.na(d$cps_cat), "Unknown", as.character(d$cps_cat)),
                      levels = c("CPS<1","CPS1-4","CPS5-9","CPS>=10","Unknown"))

  sub <- d[stats::complete.cases(d[, c("SGm","Die")]), ]
  sub$year <- droplevels(sub$year)
  dd <- rms::datadist(sub); options(datadist = dd)

  covs <- .cps_covs()
  vimp <- c("SGm","Die","Immunotherapy","log_cps","oxali","Gender","age","ECOG",
            "ratio","Grade","num_met","Histology_Lauren_Combined","burden",
            "ascites","bone","ALB","year")
  vimp <- intersect(vimp, names(sub))
  set.seed(seed)
  imp <- Hmisc::aregImpute(stats::reformulate(vimp), data = sub, n.impute = m,
                           nk = 0, pr = FALSE)

  fitm <- function(rhs) suppressWarnings(Hmisc::fit.mult.impute(
    stats::as.formula(paste("survival::Surv(SGm, Die) ~", rhs)),
    fitter = rms::cph, xtrans = imp, data = sub,
    fitargs = list(x = TRUE, y = TRUE), pr = FALSE))

  interval <- fitm(paste("Immunotherapy * cps_cat +", covs))
  bin1     <- fitm(paste("Immunotherapy * cps1 +", covs))
  bin5     <- fitm(paste("Immunotherapy * cps5 +", covs))
  bin10    <- fitm(paste("Immunotherapy * cps10 +", covs))
  spline   <- fitm(paste("Immunotherapy * rcs(log_cps, 3) +", covs))

  getp <- function(fit, pat) { a <- anova(fit); i <- grep(pat, rownames(a), fixed = TRUE)
    if (!length(i)) NA_real_ else as.numeric(a[i[1], ncol(a)]) }
  list(data = sub, imp = imp,
       interval = interval, spline = spline,
       bin1 = bin1, bin5 = bin5, bin10 = bin10,
       interaction_p = c(interval  = getp(interval, "All Interactions"),
                         spline    = getp(spline,   "All Interactions"),
                         nonlinear = getp(spline,   "Nonlinear Interaction")))
}

# Immunotherapy HR (95% CI, p) within a CPS level
.cps_hr <- function(fit, var, lev) {
  a <- stats::setNames(list(1, lev), c("Immunotherapy", var))
  b <- stats::setNames(list(0, lev), c("Immunotherapy", var))
  ct <- rms::contrast(fit, a, b)
  c(hr = unname(exp(ct$Contrast)), lo = unname(exp(ct$Lower)),
    hi = unname(exp(ct$Upper)), p = unname(ct$Pvalue))
}

.cps_stats <- function(fit) { s <- fit$stats
  c(AIC = stats::AIC(fit), C = unname(s["Dxy"]/2 + 0.5), R2 = unname(s["R2"])) }
