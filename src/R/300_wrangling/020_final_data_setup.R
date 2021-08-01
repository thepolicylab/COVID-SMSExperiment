## A file to do any necessary data cleaning before analysis and figure creation

library(here)
library(tidyverse)

## Read the csv file
dat <- read_csv(here("data", "final_counts_by_group.csv"))

### Information about the data
## first_record_date: The first date the person appeared in the file
## last_record_date: The last date the person appeared in the file
## assigned_message: Which message the person got (message_0 = control)
## message_language: The language of the message (should be English or Spanish)
## date_sent: YYYY-MM-DD date the message was assigned to be sent. Please check with Nat about the weirdness
## did_not_get_vaccinated: Does not appear to have been vaccinated (is just last_record_date == df['last_record_date'].max())
## eligible_for_text: Appeared in the file before the last file we got (is just first_record_date < df['last_record_date'].max())
## count: The total number of people who fall into the category defined by the tuple of all previous columns

## Expand data to individual level for ease of analysis.
dat_indiv <- dat %>%
  mutate(ids = map(count, seq_len)) %>%
  unnest(cols = c(ids))
## Test to make sure that the expansion worked:
with(dat_indiv, table(date_sent, assigned_message, exclude = c()))
test_indiv <- dat_indiv %>%
  group_by(date_sent, assigned_message) %>%
  summarize(count = n())
test_agg <- dat %>%
  group_by(date_sent, assigned_message) %>%
  summarize(count = sum(count))
stopifnot(all.equal(test_agg, test_indiv))

## Create the iteration variable
## Check the cut-points for the iteration variable: looks like probabilities of assignment changed at those cut-points
with(dat_indiv, table(date_sent, assigned_message, exclude = c()))

dat_indiv <- dat_indiv %>% mutate(iteration = case_when(
  date_sent <= "2021-05-28" ~ 1,
  date_sent >= "2021-06-02" & date_sent <= "2021-06-08" ~ 2,
  date_sent > "2021-06-08" ~ 3
))

with(dat_indiv, table(date_sent, iteration, exclude = c()))

## Drop missing data at analysis stage: it should not be associted with assignment at all. This is an
## administrative data issue: see 05_Prepare_Clean_Data_for_Analysis.ipynb --- some people were missing from *non-consecutive* data pulls.
##
## If someone was vaccinated before assignment, then assignment could be missing.


## Assignment happened on Wednesday morning of each week.
## People were sent messages over the following week.
## People checked the list and only sent messages to people who had not been vaccinated by that day.
## date_sent: date text was assigned to be sent (not necessarily sent --- Zayid removed people from the list who had been vaccinated.)

## Save a file for use in analysis
write_csv(dat_indiv, file = file.path(DATA_DIR, "dat_indiv.csv"))
