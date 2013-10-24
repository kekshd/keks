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
  if user.admin?
    page.should have_content "Admin"
  else
    page.should_not have_content "Admin"
  end
end

def category_select(ops = {})
  visit main_hitme_path
  fill_in "Anzahl", with: 5

  # disable xkcd comic by default to avoid loading it in testing
  first("#comiccheckbox").set(ops[:xkcd] ? true : false)

  first("#start-button").click
  should have_selector('h3', text: 'Frage')
end

def last_mail
  ActionMailer::Base.deliveries.last
end

def sent_mails
  ActionMailer::Base.deliveries
end

# Instructs Capybara to wait for AJAX requests that do not modify the
# DOM. Credit: https://coderwall.com/p/aklybw
def wait_for_non_dom_ajax
  Timeout.timeout(Capybara.default_wait_time) do
    loop do
      active = page.evaluate_script('$.active')
      break if active == 0
    end
  end
end
