# Multiple-imputation models (default seed 123): slow -> not run on CRAN.
test_that("cps_fit / cps_table2 / cps_model_comparison reproduce Table 2 (seed 123)", {
  skip_on_cran()
  # Heavy test (multiple imputation + Cox): runs only when explicitly requested,
  # with  Sys.setenv(RUN_SLOW_TESTS = "true")  before testthat.
  skip_if_not(identical(Sys.getenv("RUN_SLOW_TESTS"), "true"),
              "slow model; set RUN_SLOW_TESTS=true to run it")
  fit <- cps_fit()                       # seed = 123 by default

  # interaction: the interval (categorical) term is significant
  p <- fit$interaction_p
  expect_named(p, c("interval", "spline", "nonlinear"))
  expect_lt(p[["interval"]], 0.05)

  # Table 2: immunotherapy HR by CPS subgroup
  t2 <- cps_table2(fit)
  expect_equal(nrow(t2), 5)
  ge10 <- t2[t2$CPS_subgroup == ">=10", ]
  expect_match(ge10$HR_95CI, "^0\\.4")
  ge5  <- t2[t2$CPS_subgroup == ">=5", ]
  expect_match(ge5$HR_95CI, "^0\\.7")

  # Suppl S4: model comparison (4 models)
  mc <- cps_model_comparison(fit)
  expect_equal(nrow(mc), 4)
  expect_equal(mc$Model[which.min(mc$AIC)], "Spline")
  expect_true(all(mc$AIC > 7830 & mc$AIC < 7845))
  expect_true(all(mc$C_index > 0.66 & mc$C_index < 0.70))
})
