# encoding: utf-8

require 'spec_helper'

describe "Hitme" do
  let!(:categories) { FactoryGirl.create(:category_with_questions) }

  subject { page }

  describe "page content" do
    before { visit main_hitme_path }

    it { should have_selector('h2',    text: 'Optionen') }
    it { should have_selector('h2',    text: 'Kategorie') }
    # i.e. title not complete
    it { should_not have_selector('title', text: /^KeKs – $/) }
  end

  describe "xkcd comic", :js => true do
    before { visit main_hitme_path }

    it "is shown at the end when checked" do
      category_select({ xkcd: true })
      5.times { all('.answer-submit a.button.big[data-action="save"]').last.click }
      expect(page).to have_selector('.xkcd')
    end

    it "is not shown when unchecked" do
      category_select
      5.times { all('.answer-submit a.button.big[data-action="save"]').last.click }
      expect(page).not_to have_selector('.xkcd')
    end
  end

  describe "question answering", :js => true do
    it "has working category select" do
      visit main_hitme_path
      should have_xpath("//ul[@id='categories']/li//a[1]", visible: false)
      find(:xpath, "//a[@id='start-button']").click
      should have_selector('h3', text: 'Frage')
    end

    it "has working category select" do
      visit main_hitme_path
      find("#start-button").click
      should have_selector('h3', text: 'Frage')
      should have_selector('.answer-chooser')
      should have_selector('.alert-error', visible: false)
      should have_selector('.alert-success', visible: false)
    end

    it "can be finished" do
      category_select
      5.times { all('.answer-submit a.button.big[data-action="save"]').last.click }
      should have_selector('h3', text: 'Fertig!')
    end

    it "updates stats" do
      def print_stats(pre = "")
        puts "#{pre} c:#{Stat.where(correct: true).size}  f:#{Stat.where(correct: false).size}  a:#{Stat.all.size}"
      end

      expect do
        category_select
        3.times {
          expect do
            # select correct answer to easily distinguish these stats
            # from others inserted by race conditions
            all('a.button.toggleable[data-correct="true"]').each { |l| l.click }
            all('.answer-submit a.button.big[data-action="save"]').last.click
            wait_for_non_dom_ajax
          end.to change { Stat.where(correct: true).size }.by(1)
        }
      end.to change { Stat.where(correct: true).size }.by(3)
    end
  end

  describe "starred questions", :js => true do
    let(:user) { FactoryGirl.create(:user) }

    it "doesn’t show feature for non-logged in users" do
      category_select
      should_not have_content "Frage merken"
      should_not have_content "Frage gemerkt"
    end

    it "show for logged in users" do
      sign_in(user)
      category_select
      should have_content "Frage merken"
    end

    it "are stored to the database" do
      sign_in(user)
      category_select
      should have_content "Frage merken"
      expect {
        first(".star a").click
        should have_content "Frage gemerkt"
      }.to change { Question.all.map { |q| q.starred_by.size }.inject(:+) }.by(1)

      visit starred_path(user)
      should have_selector('h3', text: 'Frage')
      should have_content "Frage gemerkt"
      expect {
        first(".star a").click
        should have_content "Frage merken"
      }.to change { Question.all.map { |q| q.starred_by.size }.inject(:+) }.by(-1)
    end
  end
end
