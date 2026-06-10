test_that("CPS distribution reproduces the paper", {
  dis <- cps_distribution()
  expect_equal(dis$n_evaluable, 729)
  # binary thresholds: >=1 = 611, >=5 = 460, >=10 = 290
  expect_equal(dis$binary$n, c(611, 460, 290))
  expect_equal(dis$binary$pct, c(83.8, 63.1, 39.8))
  # non-overlapping intervals: 118 / 151 / 170 / 290
  expect_equal(dis$intervals$n, c(118, 151, 170, 290))
  expect_equal(sum(dis$intervals$n), 729)
})
