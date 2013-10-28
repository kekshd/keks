# encoding: utf-8

require 'spec_helper'

describe QuestionsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:admin) { FactoryGirl.create(:admin) }
  let(:reviewer) { FactoryGirl.create(:reviewer) }
  let(:question) { FactoryGirl.create(:question) }
  let(:question_full) { FactoryGirl.create(:question_parent_category) }
  let!(:existing_question) { FactoryGirl.create(:question_with_answers) }
  let!(:existing_category) { FactoryGirl.create(:category) }

  render_views

  it "renders perma template for everyone" do
    get :perma, id: existing_question.id
    response.should render_template :perma
    response.body.should have_content existing_question.id
  end

  it "renders questions index for admins" do
    sign_in admin
    existing_question
    a = existing_question.answers.sample
    get :index
    response.should render_template :index
    expect(response.status).to eq(200)
    expect(response.body).to include(existing_question.ident, a.id.to_s, a.text)
  end

  it "renders question details for admins" do
    sign_in admin
    get :show, id: existing_question.id
    response.should render_template :show
    response.body.should have_content existing_question.ident
  end

  it "allows admins to toggle question release status" do
    sign_in admin
    request.env["HTTP_REFERER"] = question_path(question)
    put :toggle_release, question_id: question.id
    flash[:success].should_not be_nil
    flash[:error].should be_nil
    question.reload
    question.released?.should == false
    question.complete?.should == false
  end

  it "shows an error when toggling fails" do
    sign_in admin
    Question.stub(:find).and_return {
      question.stub(:save).and_return(false)
      question
    }
    put :toggle_release, question_id: question.id
    flash[:error].should_not be_nil
  end

  it "renders new template for admins" do
    sign_in admin
    get :new
    response.should render_template :new
  end

  it "renders new template for admins with category pre-selected" do
    sign_in admin
    get :new, parent: "Category_#{existing_category.id}"
    response.should render_template :new
    page = Capybara::Node::Simple.new(response.body)
    expect(page).to have_select('parent', selected: existing_category.ident)
  end

  it "renders new template for admins with answer pre-selected" do
    sign_in admin
    answ = existing_question.answers.first
    get :new, parent: "Answer_#{answ.id}"
    response.should render_template :new
    page = Capybara::Node::Simple.new(response.body)
    expect(page).to have_select('parent', selected: "#{existing_question.ident}/#{answ.id}")
  end


  describe "#create" do
    before(:each) do
      sign_in admin
      @good_attr = {"utf8"=>"✓", "authenticity_token"=>"S1dVBhTWOqkzwOdTBRvVcLBUs4Gsr/9z+paAzT0p4X0=", "question"=>{"ident"=>"123", "text"=>"123", "difficulty"=>"5", "study_path"=>"1", "released"=>"0"}, "parent"=>"Category_#{existing_category.id}", "commit"=>"Frage anlegen"}
    end

    it "re-renders new template on failed save" do
      post :create
      assigns[:question].should be_new_record
      flash[:success].should be_nil
      response.should render_template :new
    end

    it "re-renders new template when missing required fields" do
      attr = @good_attr.dup
      attr["question"].delete("ident")
      post :create, attr
      assigns[:question].should be_new_record
      flash[:success].should be_nil
      response.should render_template :new
    end

    it "shows question on successful save" do
      post :create, @good_attr
      flash[:success].should_not be_nil
      response.should redirect_to question_path(Question.where(ident: "123").first)
    end
  end

  it "destroys question" do
    sign_in admin
    expect {
      expect {
        delete :destroy, id: existing_question.id
      }.to change(Question, :count)
    }.to change(Answer, :count)
    flash[:success].should_not be_nil
    response.should redirect_to questions_path
  end

  it "shows error when destroying fails" do
    sign_in admin
    Question.stub(:find).and_return {
      question.stub(:destroy).and_return(false)
      question
    }
    delete :destroy, id: question.id
    flash[:error].should_not be_nil
    response.should redirect_to questions_path
  end

  it "renders edit page" do
    sign_in admin
    get :edit, id: question_full.id
    expect(response).to render_template :edit
  end

  describe "#update" do
    before(:each) do
      sign_in admin
      @new_ident = "new_test_ident"
      @q = existing_question
      @p = existing_category
      post :update, id: @q.id,
          question: { ident: @new_ident },
          parent: "#{@p.class}_#{@p.id}"
      existing_question.reload
    end

    it "updates question" do
      expect(flash[:error]).to be_nil
      expect(flash[:success]).not_to be_nil
      expect(existing_question.ident).to eq(@new_ident)
      expect(existing_question.parent_id).to eq(@p.id)
      expect(existing_question.parent_type).to eq(@p.class.to_s)

      response.should redirect_to existing_question
    end

    it "writes content_changed_at" do
      @q.reload
      expect(@q.content_changed_at).to be > Time.now - 60
    end
  end

  it "re-renders edit template on failed save" do
    sign_in admin
    new_ident = ""
    q = existing_question
    p = existing_category
    post :update, id: q.id, question: { ident: new_ident }, parent: "#{p.class}_#{p.id}"
    expect(response).to render_template :edit
  end

  it "re-renders edit template when given invalid parent" do
    sign_in admin
    new_ident = ""
    q = existing_question
    post :update, id: q.id, question: { ident: new_ident }
    expect(response).to render_template :edit
  end

  describe "#overwrite_reviews" do
    before :each do
      sign_in admin
      @q = FactoryGirl.create(:question_with_many_good_reviews)
    end

    it "shows success message" do
      put :overwrite_reviews, question_id: @q.id
      expect(flash[:success]).not_to be_nil
    end

    it "doesn’t touch anything if nothing to do" do
      upd = @q.updated_at
      put :overwrite_reviews, question_id: @q.id
      @q.reload
      expect(@q.updated_at.to_s).to eql(upd.to_s)
    end

    it "leaves only okay reviews afterwards" do
      r = @q.reviews.sample
      r.okay = false
      r.save
      put :overwrite_reviews, question_id: @q.id
      all_okay = @q.reviews.all? { |r| r.reload; r.okay? }
      expect(all_okay).to be true
    end

    it "mentions admin in updated reviews" do
      r = @q.reviews.sample
      r.okay = false
      r.save
      put :overwrite_reviews, question_id: @q.id
      r.reload
      expect(r.comment).to include(admin.nick)
    end
  end

  describe "#copy" do
    before { sign_in admin }

    it "renders copy form" do
      get :copy, question_id: question.id
      expect(response).to render_template('_copy')
    end

    it "has an abort button" do
      get :copy, question_id: question.id
      expect(response.body).to include('Abbrechen')
    end
  end

  describe "#copy_to" do
    before { sign_in admin }

    context "with existing ident" do
      def copy
        q = existing_question
        post :copy_to, question_id: q.id, ident: q.ident, copy_answers: "1"
      end

      it "returns to previous question" do
        copy
        expect(response).to redirect_to existing_question
      end

      it "shows an error" do
        copy
        expect(flash[:error]).not_to be_nil
      end

      it "doesn’t add answers" do
        expect { copy }.not_to change { Answer.count }
      end

      it "doesn’t add hints" do
        expect { copy }.not_to change { Hint.count }
      end

      it "doesn’t add new question" do
        expect { copy }.not_to change { Question.count }
      end
    end

    context "with unique ident" do
      before { @s = existing_question }

      def copy(copy_answers = true, copy_hints = true)
        ca = copy_answers ? "1" : "0"
        ch = copy_hints ? "1" : "0"
        post :copy_to, question_id: @s.id,
          ident: @s.ident + "_copy", copy_answers: ca, copy_hints: ch
        @q = Question.where(ident: @s.ident + "_copy").first
      end

      it "redirects to copied question" do
        copy
        expect(response).to redirect_to @q
      end

      it "shows a success message" do
        copy
        expect(flash[:success]).not_to be_nil
      end

      it "adds as much answers as the source question has" do
        expect { copy }.to change { Answer.count }.by(@s.answers.count)
      end

      it "adds as much hints as the source question has" do
        expect { copy }.to change { Hint.count }.by(@s.hints.count)
      end

      it "doesn’t produce a warning when copying answers and hints" do
        copy
        expect(flash[:warning]).to be_nil
      end

      it "adds one new question" do
        expect { copy }.to change { Question.count }.by(1)
      end

      it "creates a valid copy" do
        expect(copy).to be_valid
      end

      it "doesn’t carry over the reviews" do
        expect(copy.reviews.count).to eql 0
      end

      it "doesn’t copy answers if unchecked" do
        expect { copy(false) }.not_to change { Answer.count }
      end

      it "doesn’t copy hints if unchecked" do
        expect { copy(false, false) }.not_to change { Hint.count }
      end
    end
  end
end
