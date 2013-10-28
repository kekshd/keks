# encoding: utf-8

require 'spec_helper'

describe Category do
  let(:category) { FactoryGirl.create(:category) }

  it "can be saved" do
    expect(category).to be_valid
  end

  it "can be traced to root" do
    expect(category.trace_to_root).to include(category.title)
  end

  it "generates link text" do
    expect(category.link_text).to include(category.ident)
  end

  it "includes the answers that link to it when tracing to root" do
    q = FactoryGirl.create(:question_parent_category_subs)
    a = q.answers.first
    category.answers << a
    category.is_root = false
    category.save
    expect(category.trace_to_root).to include(a.id.to_s)
  end

  it "retrieves correct root categories" do
    q = FactoryGirl.create(:question_parent_category_subs)
    cats = q.answers.map { |a| a.categories }.flatten
    root_cat_ids = Category.where(is_root: true).pluck(:id)
    cats.each do |c|
      ids = c.get_root_categories.map { |c| c.id }
      expect(ids).to include(*root_cat_ids)
      expect(ids).not_to include(*(cats.map { |cc| cc.id }))
    end
  end

  it "renders dot" do
    c = FactoryGirl.create(:question_parent_category_subs).parent
    dot = c.dot
    expect(dot).to include(c.dot_id)
  end

  it "renders dot region with neighbors" do
    q = FactoryGirl.create(:question_parent_category_subs)
    c = q.parent
    subcat = q.subcategories.first
    expect(c.dot_region).to include(c.dot_id, q.ident,
                              q.subquestions.first.ident, subcat.ident)

    expect(subcat.dot_region).to include(subcat.answers.first.id.to_s)
  end
end
