# encoding: utf-8

require 'spec_helper'

describe "Registration" do
  subject { page }

  before { visit signup_path }

  describe "page content" do
    it { should have_selector('h2',    text: 'Neuen Account anlegen') }
    it { should_not have_selector('title', text: /^KeKs – $/) }
  end

  describe "submitting form" do
    before {
      fill_in "Nick", with: "testuser"
      fill_in "Passwort", with: "derp"
      fill_in "Bestätigung", with: "derp"
      click_button "Account anlegen"
    }

    it { should have_text "Du bist jetzt angemeldet." }
  end
end
