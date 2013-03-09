Given /^a user visits the signin page$/ do
  visit signin_path
end

When /^he submits invalid signin information$/ do
  click_button "Einloggen"
end

Then /^he should see an error message$/ do
  page.should have_selector('.alert-error')
end

Given /^the user has an account$/ do
  #@user = User.create(nick: "Example User", mail: "user@example.com",
  #                    password: "foobar", password_confirmation: "foobar")
  @user = FactoryGirl.create(:user)
end

When /^the user submits valid signin information$/ do
  visit signin_path
  fill_in "Nick",     with: @user.nick
  fill_in "Password", with: @user.password 
  click_button "Einloggen"
end

Then /^he should see the hitme page$/ do
  page.should have_selector('title', text: 'Fragen beantworten')
end

Then /^he should see a signout link$/ do
  page.should have_link('Ausloggen', href: signout_path)
end
