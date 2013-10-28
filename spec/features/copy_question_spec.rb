# encoding: utf-8

require 'spec_helper'

describe 'Copy Question' do
  let(:admin) { FactoryGirl.create(:admin) }
  let!(:question) { FactoryGirl.create(:question_with_answers) }

  subject { page }

  before do
    sign_in admin
    visit question_path(question)
  end

  it { should have_selector('a', text: 'Kopieren') }

  describe "popup", js: true do
    before {
      click_link "Kopieren", match: :first
      fill_in "Ident", with: "new_unique_ident_please"
    }

    it { should have_field('Ident') }
    it { should have_field('Antworten kopieren') }
    it { should have_button('Kopieren') }
    it { should have_selector('a', text: 'Abbrechen') }

    describe "cancelled" do
      before { click_link "Abbrechen" }

      it { should_not have_button('Kopieren') } # i.e. popup closed?
    end


    describe "submitted" do
      before { click_button "Kopieren" }

      it { should have_content('new_unique_ident_please') }
      it { should have_content(question.answers.sample.text[0..20]) }
      it { should have_content(question.hints.sample.text[0..20]) }
    end
  end
end
