#' A file to do any necessary data cleaning before analysis and figure creation
#'
#' Note that this file is outdated as we eventually moved to line list level
#' data instead of aggreated data. See 020_final_data_setup for details.

library(here)
source(here("src", "R", "300_wrangling", "000_constants.R"))

## Using tidyverse rather than data.table because (1) the data are not so large
## and (2) tidy and base R approaches are easier to read for new R users
library(tidyverse)

## Read the csv file
dat_anyvax <- read_csv(file.path(DATA_DIR, "counts_from_vax_list_anytime_after_send.csv"))
dat_weekvax <- read_csv(file.path(DATA_DIR, "counts_from_vax_list_within_one_week_after_send.csv"))



## Expand data to individual level for ease of analysis.
dat_anyvax_indiv <- dat_anyvax %>%
  mutate(ids = map(count, seq_len)) %>%
  unnest(cols = c(ids))

## Test to make sure that the expansion worked:
with(dat_anyvax_indiv, table(date_sent, assigned_message, exclude = c()))
test_anyvax_indiv <- dat_anyvax_indiv %>%
  group_by(date_sent, assigned_message) %>%
  summarize(count = n()) %>%
  ungroup()
test_anyvax_agg <- dat_anyvax %>%
  group_by(date_sent, assigned_message) %>%
  summarize(count = sum(count)) %>%
  ungroup()
stopifnot(all.equal(test_anyvax_agg, test_anyvax_indiv))

dat_weekvax_indiv <- dat_weekvax %>%
  mutate(ids = map(count, seq_len)) %>%
  unnest(cols = c(ids))

## Test to make sure that the expansion worked:
with(dat_weekvax_indiv, table(date_sent, assigned_message, exclude = c()))
test_weekvax_indiv <- dat_weekvax_indiv %>%
  group_by(date_sent, assigned_message) %>%
  summarize(count = n()) %>%
  ungroup()
test_weekvax_agg <- dat_weekvax %>%
  group_by(date_sent, assigned_message) %>%
  summarize(count = sum(count)) %>%
  ungroup()
stopifnot(all.equal(test_weekvax_agg, test_weekvax_indiv))

all.equal(test_weekvax_agg, test_anyvax_agg)
all.equal(test_weekvax_indiv, test_anyvax_indiv)

test_weekvax_dat <- dat_weekvax_indiv %>% select(assigned_message, message_language, date_sent, is_chosen_from_uniform)
test_anyvax_dat <- dat_anyvax_indiv %>% select(assigned_message, message_language, date_sent, is_chosen_from_uniform)

stopifnot(all.equal(test_weekvax_dat, test_anyvax_dat))

dat_indiv <- dat_anyvax_indiv
dat_indiv$is_within_one_week_after_send <- dat_weekvax_indiv$is_within_one_week_after_send
with(dat_indiv, table(is_vax_after_send, is_within_one_week_after_send, exclude = c()))

## Toplines/Raw proportions
dat_indiv %>%
  group_by(assigned_message) %>%
  summarize(prop_anyvax = mean(is_vax_after_send), prop_vaxinweek = mean(is_within_one_week_after_send))

## Save a file for use in analysis
write_csv(dat_indiv, file = file.path(DATA_DIR, "dat_indiv.csv"))
