include ApplicationHelper

def sign_in(user)
  visit signin_path
  fill_in "Nick",     with: user.mail
  fill_in "Password", with: user.password
  click_button "Einloggen"
  # Sign in when not using Capybara as well.
  cookies[:remember_token] = user.remember_token
end
