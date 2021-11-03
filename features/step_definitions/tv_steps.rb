Given(/^Initialize test "([^"]*)"$/) do |arg|
  puts 'Inicia el test'
end

Given(/^I validate label "([^"]*)"$/) do |arg|
  puts 'Validando un Label'
end

When(/^I pause the player$/) do
  puts 'Press button pause'
end

Then(/^I navigate between the movies$/) do
  puts 'Navegando entre los contenidos'
end