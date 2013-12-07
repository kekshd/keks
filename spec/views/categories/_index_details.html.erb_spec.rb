# encoding: utf-8

require "spec_helper"

describe "categories/_index_details.html.erb" do
  let(:admin) { FactoryGirl.create(:admin) }
  let(:category) { FactoryGirl.create(:category_with_questions) }


  describe "manually resolved links are correct" do
    before(:each) do
      render partial: "index_details", locals: { cats: [category] }
    end

    it "has correct toggle links for users" do
      q = category.questions.sample
      expect(rendered).to have_link(q.ident, href: question_path(q.id))
    end
  end
end
