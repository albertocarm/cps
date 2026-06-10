test_that("cps_prepare builds the analysis factors", {
  d <- cps_prepare()
  expect_true(all(c("arm", "cps_cat", "cps1", "cps5", "cps10", "burden") %in% names(d)))
  # log_cps is derived from cps at run time (not shipped with the data)
  expect_equal(d$log_cps, log(d$cps + 0.1))
  # arm labels
  expect_equal(levels(d$arm), c("CT alone", "CT + ICI"))
  # non-overlapping CPS intervals keep an explicit "Unknown" level
  expect_equal(levels(d$cps_cat), c("CPS<1", "CPS1-4", "CPS5-9", "CPS>=10", "Unknown"))
  # hepatic burden level 0 = "No liver involvement" has 728 patients
  expect_equal(unname(table(d$burden)["No liver involvement"]), 728)
  # CPS-missing are all coded as the "Unknown" level (none dropped)
  expect_equal(sum(d$cps_cat == "Unknown"), sum(is.na(d$cps)))
})
