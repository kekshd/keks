# encoding: utf-8

require 'spec_helper'

describe CategoriesController do
  let(:admin) { FactoryGirl.create(:admin) }
  let(:answer) { FactoryGirl.create(:answer) }
  let(:category) { FactoryGirl.create(:category) }
  let(:category2) { FactoryGirl.create(:category) }
  let(:cat_with_q) { FactoryGirl.create(:category_with_questions) }

  render_views

  before(:each) do
    sign_in admin
  end

  describe "#index" do
    it "renders index template" do
      get :index
      expect(response).to render_template("index")
    end
  end

  describe "#show" do
    it "renders show template" do
      get :show, id: category.id
      expect(response).to render_template("show")
    end
  end

  describe "#new" do
    it "renders new template" do
      get :new
      expect(response).to render_template("new")
    end

    it "ignores invalid parent id" do
      get :new, parent: answer.id + 1
      expect(response).to render_template("new")
    end

    it "preselects given parent" do
      get :new, parent: answer.id
      sel = "option[value='#{answer.id}'][selected]"
      expect(response.body).to have_selector(sel)
    end
  end

  describe "#edit" do
    it "renders edit template" do
      get :edit, id: category.id
      expect(response).to render_template("edit")
    end

    it "redirects to category list for non-existing category" do
      get :edit, id: 9912939123123123436345
      expect(response).to redirect_to categories_path
    end
  end

  describe "#create" do
    before(:each) do
      post :create, category: {
        title: "title",
        ident: "le id",
        text: "description"
      }
      @cat = Category.find { |c| c.ident == "le id" }
    end

    it "reports success" do
      expect(flash[:success]).not_to be_nil
    end

    it "shows category afterwards" do
      expect(response).to redirect_to category_path(@cat.id)
    end
  end

  describe "#create with existing ident" do
    before(:each) do
      other = category
      post :create, category: {
        title: "title",
        ident: other.ident,
        text: "description"
      }
    end

    it "renders new template again" do
      expect(response).to render_template(:new)
    end

    it "shows an error" do
      expect(response.body).to have_selector(".field_with_errors")
    end
  end

  describe "#create with parent answers" do
    before(:each) do
      post :create, category: {
        title: 'title',
        ident: 'le id',
        is_root: '0',
        answer_ids: [answer.id.to_s]
      }
      @cat = Category.find { |c| c.ident == "le id" }
    end

    it 'reports success' do
      expect(flash[:success]).not_to be_nil
    end

    it 'has the given answers as parents' do
      expect(@cat.answers.map(&:id)).to include(answer.id)
      expect(@cat.answers.size).to eql(1)
    end
  end

  describe "#update" do
    before(:each) do
      post :update, id: category.id, category: {
        title: "new title"
      }
      category.reload
    end

    it "record in db" do
      expect(category.title).to eql("new title")
    end

    it "reports success" do
      expect(flash[:success]).not_to be_nil
    end

    it "returns to category" do
      expect(response).to redirect_to category_path(category.id)
    end
  end

  describe "#update with parent answers" do
    before(:each) do
      post :update, id: category.id, category: {
        title: "new title",
        is_root: '0',
        answer_ids: [answer.id.to_s]
      }
      category.reload
    end

    it 'has the given answers as parents' do
      expect(category.answers.map(&:id)).to include(answer.id)
      expect(category.answers.size).to eql(1)
    end
  end

  describe "#update with existing ident" do
    before(:each) do
      post :update, id: category.id, category: {
        ident: category2.ident,
        title: "new title"
      }
      category.reload
    end

    it "renders edit template again" do
      expect(response).to render_template(:edit)
    end

    it "shows an error" do
      expect(response.body).to have_selector(".field_with_errors")
    end
  end

  describe "#destroy" do
    it "removes category from DB" do
      category
      expect {
        delete :destroy, id: category.id
      }.to change(Category, :count)
      expect(flash[:success]).not_to be_nil
    end

    it "keeps associated questions intact" do
      cat_with_q
      expect {
        delete :destroy, id: cat_with_q.id
      }.not_to change(Question, :count)
    end
  end

  describe "#release" do
    before do
      get :release, id: cat_with_q.id
      cat_with_q.reload
    end

    it "sets category and questions to released" do
      expect(cat_with_q.released).to eql true
      all_q_released = cat_with_q.questions.all? { |q| q.released? }
      expect(all_q_released).to eql true
    end

    it "reports success" do
      expect(flash[:success]).not_to be_nil
    end

    it "returns to category" do
      expect(response).to redirect_to category_path(cat_with_q.id)
    end
  end

  describe "#suspicious_associations" do

    it "renders suspicious assocations template" do
      get :suspicious_associations
      expect(response).to render_template(:suspicious_associations)
    end

    it "doesn’t report all correct assocs" do
      FactoryGirl.create(:question_parent_category_subs)
      get :suspicious_associations
      expect(response.body).to have_text("Nichts gefunden")
    end

    it "detects suspicious assocations" do
      catA = FactoryGirl.create(:category_with_questions)
      catB = FactoryGirl.create(:category_with_questions, is_root: false)

      # connect all but one answer from catA to act as parent for catB
      first = true
      catA.questions.each do |q|
        q.answers.each do |a|
          if first
            first = false
            next
          end
          a.categories << catB
          a.save
        end
      end

      get :suspicious_associations
      expect(response.body).not_to have_text("Nichts gefunden")
    end
  end
end
