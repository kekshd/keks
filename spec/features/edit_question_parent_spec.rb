# encoding: utf-8

require 'spec_helper'

describe 'editing question with parent selection subform', js: true do
  let(:admin) { FactoryGirl.create(:admin) }
  let!(:category) { FactoryGirl.create(:category) }
  let!(:answer) { FactoryGirl.create(:answer_with_subquestion) }

  subject { page }

  before do
    @question = answer.questions.first
    sign_in admin, true
    visit edit_question_path(@question)
  end

  it { should have_text(@question.parent.link_text) }

  it "does not change parent on submit" do
    click_button "Speichern"
    should have_link @question.parent.link_text
  end

  context "after clicking edit link" do
    before { find("a", text: "anderes Eltern-Element wählen").click }

    it { should have_text('vorhergehende Fragen und Kategorien zuerst') }
    it { should have_select('parent') }
    it { should have_select('parent', selected: @question.parent.link_text_short) }

    it "does not change parent on submit" do
      click_button "Speichern"
      should have_link @question.parent.link_text
    end

    it "allows parent to be changed" do
      select category.ident, from: "parent"
      click_button "Speichern"
      should have_link category.link_text
    end
  end
end
