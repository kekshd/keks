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

  #~　describe "question answering", :js => true do
    #~　it "has working category select" do
      #~　visit main_hitme_path
      #~　should have_xpath("//ul[@id='categories']/li//a[1]")
      #~　find(:xpath, "//ul[@id='categories']/li//a[1]").click
      #~　find(:xpath, "//a[@id='start-button']").click
      #~　should have_selector('h3', text: 'Frage')
    #~　end
#~　
    #~　it "has working category select" do
      #~　visit main_hitme_path
      #~　find("#start-button").click
      #~　should have_selector('h3', text: 'Frage')
      #~　should have_selector('.answer-chooser')
      #~　should have_selector('.alert-error', visible: false)
      #~　should have_selector('.alert-success', visible: false)
    #~　end
#~　
    #~　it "can be finished" do
      #~　category_select
      #~　5.times { all('.answer-submit a.button.big[data-action="save"]').last.click }
      #~　should have_selector('h3', text: 'Fertig!')
    #~　end
#~　
    #~　it "updates stats" do
      #~　expect do
        #~　category_select
        #~　3.times { all('.answer-submit a.button.big[data-action="save"]').last.click }
        #~　sleep 0.5
      #~　end.to change { Stat.all.size }.by(3)
    #~　end
  #~　end
#~　
  #~　describe "starred questions", :js => true do
    #~　let(:user) { FactoryGirl.create(:user) }
#~　
    #~　it "doesn’t show feature for non-logged in users" do
      #~　category_select
      #~　should_not have_content "Frage merken"
      #~　should_not have_content "Frage gemerkt"
    #~　end
#~　
    #~　it "show for logged in users" do
      #~　sign_in(user)
      #~　category_select
      #~　should have_content "Frage merken"
    #~　end
#~　
    #~　it "are stored to the database" do
      #~　sign_in(user)
      #~　category_select
      #~　should have_content "Frage merken"
      #~　expect {
        #~　first(".star a").click
        #~　should have_content "Frage gemerkt"
      #~　}.to change { Question.all.map { |q| q.starred_by.size }.inject(:+) }.by(1)
#~　
      #~　visit starred_path(user)
      #~　should have_selector('h3', text: 'Frage')
      #~　should have_content "Frage gemerkt"
      #~　expect {
        #~　first(".star a").click
        #~　should have_content "Frage merken"
      #~　}.to change { Question.all.map { |q| q.starred_by.size }.inject(:+) }.by(-1)
    #~　end
  #~　end
end
