# encoding: utf-8

require 'spec_helper'

describe "Hitme" do
  let!(:categories) { FactoryGirl.create(:category_with_questions)}

  subject { page }

  #~ describe "hitme page" do
    #~ before { visit main_hitme_path }
#~
    #~ it { should have_selector('h2',    text: 'Optionen') }
    #~ it { should have_selector('h2',    text: 'Kategorie') }
    #~ # i.e. title not complete
    #~ it { should_not have_selector('title', text: /^Keks – $/) }
  #~ end

  describe "hitme walkthrough", :js => true do
    it "has working category select" do
      visit main_hitme_path
      should have_xpath("//ul[@id='categories']/li//a[1]")
      find(:xpath, "//ul[@id='categories']/li//a[1]").click
      should have_selector('a', text: 'Frage merken')
      should have_selector('h3', text: 'Frage')
    end

    it "has working category select" do
      visit main_hitme_path
      should have_xpath("//ul[@id='categories']/li//a[1]")
      find(:xpath, "//ul[@id='categories']/li//a[1]").click
      should have_selector('a', text: 'Frage merken')
      should have_selector('h3', text: 'Frage')
      should have_selector('.answer-chooser')
      should have_selector('.alert-error')
      should have_selector('.alert-success')
    end

    it "can be finished" do
      #~ visit main_hitme_path
      #~ fill_in "Anzahl", with: 5
      #~ find(:xpath, "//ul[@id='categories']/li//a[1]").click
      #~ 20.times {       pp find("a.button:last").text; find("a.button:last").click }
#~
      #~ should have_selector('h3', text: 'Fertig!')
    end
  end
end
