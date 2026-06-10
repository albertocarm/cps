test_that("bundled dataset is the de-identified 1040-patient cohort", {
  data(agamenon_cps, package = "cps")
  expect_s3_class(agamenon_cps, "data.frame")
  expect_equal(nrow(agamenon_cps), 1040)
  # analysis variables are shared (18 columns, incl. year + ALB)
  expect_equal(ncol(agamenon_cps), 18)
  # identifier and non-analysis fields must be absent
  expect_false(any(c("ID", "days_pfs", "status_PFS_1L",
                     "CEA", "alb_recoded", "Triplet",
                     "FGFR alteration", "log_cps") %in% names(agamenon_cps)))
  # treatment arms: CT alone = 615, CT + ICI = 425
  expect_equal(as.integer(table(agamenon_cps$Immunotherapy)[c("0", "1")]), c(615L, 425L))
  # CPS evaluable = 729
  expect_equal(sum(!is.na(agamenon_cps$cps)), 729)
})
