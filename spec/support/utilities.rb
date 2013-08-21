# encoding: utf-8

include ApplicationHelper

def sign_in(user)
  visit signin_path
  fill_in "Nick",     with: user.nick
  fill_in "Passwort", with: user.password
  click_button "Einloggen"
  # Sign in when not using Capybara as well.
  cookies[:remember_token] = user.remember_token
  page.should_not have_content "Nutzername unbekannt oder Passwort ungültig"
  page.should have_content "eingeloggt als"
end

def category_select
  wait_for_ajax(page)
  visit main_hitme_path
  fill_in "Anzahl", with: 5
  first("#start-button").click
  sleep 0.5
  should have_selector('h3', text: 'Frage')
end
