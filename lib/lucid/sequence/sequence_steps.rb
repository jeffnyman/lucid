# The only test definitions that should go in here are those that
# will build sequence steps. Meaning, each test step here is meant
# to be one that is equivalent to a sequence of test steps.

Given(/^the step "(?:Given|When|Then|\*) \[((?:[^\\\]]|\\.)+)\](:?)" is defined to mean:$/) do |phrase, table, sequence|
  data_provided = (table == ':')
  add_sequence(phrase, sequence, data_provided)
end