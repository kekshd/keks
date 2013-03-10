include ApplicationHelper

def sign_in(user)
  visit signin_path
  fill_in "Nick",     with: user.nick
  fill_in "Password", with: user.password
  click_button "Einloggen"
  # Sign in when not using Capybara as well.
  cookies[:remember_token] = user.remember_token
  should have_content "eingeloggt als"
end

def category_select
  wait_for_ajax(page)
  visit main_hitme_path
  fill_in "Anzahl", with: 5
  first("#categories a").click
  should have_selector('h3', text: 'Frage')
  sleep 0.4
end
