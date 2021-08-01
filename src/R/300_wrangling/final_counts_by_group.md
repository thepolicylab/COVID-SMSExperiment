first_record_date: The first date the person appeared in the file
last_record_date: The last date the person appeared in the file
assigned_message: Which message the person got (message_0 = control)
message_language: The language of the message (should be English or Spanish)
date_sent: YYYY-MM-DD date the message was assigned to be sent. Please check with Nat about the weirdness
did_not_get_vaccinated: Does not appear to have been vaccinated (is just last_record_date == df['last_record_date'].max())
eligible_for_text: Appeared in the file before the last file we got (is just first_record_date < df['last_record_date'].max())
count: The total number of people who fall into the category defined by the tuple of all previous columns
