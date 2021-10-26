## Simulations to assess the extent to which decreasing sample size by excluding
## possibly invalid zeros would increase effect size fast enough to increase
## statistical power.

library(estimatr)
library(tidyverse)

## Make a data set with 5 vaccinations in treatment and 4 in control
## with varying numbers of non-vaccinations --- same in both conditions.
check_prop_diff <- function(N, n_pos_trt = 5, n_pos_ctrl = 4) {
  dat <- data.frame(
    y = c(
      rep(1, n_pos_trt), rep(0, N - n_pos_trt),
      rep(1, n_pos_ctrl), rep(0, N - n_pos_ctrl)
    ),
    z = rep(c(1, 0), each = N)
  )
  ## Using Neyman randomization standard errors and large sample-based p-values
  lm_robust(y ~ z, data = dat) %>%
    tidy() %>%
    select(term, estimate, p.value, df)
}

## in 020_effects_on_vaccinations.Rmd we see that 265 total people in the
## control group were vaccinated.
##
## > plotdat1 %>% group_by(mtype) %>% summarize(tot_vac=sum(nvac),tot_n=sum(N),prop_vac=tot_vac/tot_n)
## # A tibble: 9 x 4
##   mtype                              tot_vac tot_n prop_vac
##   <chr>                                <dbl> <int>    <dbl>
## 1 Access                                 337 15243   0.0221
## 2 Control                                265 11327   0.0234
## 3 Epistemic humility+no bad outcomes     213 10110   0.0211
## 4 Family concern                         599 47058   0.0127
## 5 Ownership                              228 10491   0.0217
## 6 Preventing bad outcomes                289 11962   0.0242
## 7 Safety                                 290 12440   0.0233
## 8 Social proof                           249 12363   0.0201
## 9 Social proof+family concern            274 11434   0.0240

## Let us imagine a simpler designed study, where we have no blocking and
## equal probabilities of assignment to two arms, with each arm having 15,000
## units.

## Imagine that we have 265 vaccinations in control and 300 in treatment (ignoring the Family
## Concern treatment above since the size of that arm is much larger than the
## other arms).

## This would make our estimate of an effect about .002.
(300 / 15000) - (265 / 15000)

## In this scenario we have the following result (p=.1371, est ate=.0023)
## Noting here that we would have **more** statistical power in our
## block-randomized design than we do here.
check_prop_diff(N = 15000, n_pos_trt = 300, n_pos_ctrl = 265)

## What if 2/3 of our N=30,000 was zero?
## Total N would be
30000 * (1 / 3)
## So each arm would be
(30000 * (1 / 3)) * 1 / 2
## In this scenario we have the following result (p=.1296, est ate=.007)
check_prop_diff(N = 5000, n_pos_trt = 300, n_pos_ctrl = 265)

## What if we only have 1000 people in each arm? (p=.08, est ate=.03)
check_prop_diff(N = 1000, n_pos_trt = 300, n_pos_ctrl = 265)

## There is a limit to the extent to which sample size decreasing overwhelms
## effect size: if close to 99% of the zeros were invalid, then we would have a
## huge effect size:
check_prop_diff(N = 350, n_pos_trt = 300, n_pos_ctrl = 265)

## Other smaller scenarios with fixed numbers of positive responses.
check_prop_diff(N = 1000)
check_prop_diff(N = 100)
check_prop_diff(N = 50)
check_prop_diff(N = 25)
