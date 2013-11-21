# encoding: utf-8

require 'spec_helper'

describe MainController do
  let(:user) { FactoryGirl.create(:user) }

  render_views

  it "renders help page" do
    get :help
    expect(response).to render_template(:help)
  end

  describe "#feedback" do
    it "uses feedback template" do
      get :feedback
      expect(response).to render_template(:feedback)
    end

    it "includes text given via params" do
      get :feedback, text: "this is a test text"
      expect(response.body).to include("this is a test text")
    end
  end

  describe "#questions" do
    it "automatically selects root categories if none given" do
      FactoryGirl.create(:category_with_questions)
      get :questions, count: 5
      expect { JSON.parse(response.body) }.not_to raise_error
      expect(JSON.parse(response.body)).to be_a(Array)
    end

    it "raises when given invalid data" do
      FactoryGirl.create(:category_with_questions)
      expect {
        controller.stub!(:json_for_question).and_return(["borken"])
        get :questions, count: 5
      }.to raise_error
    end
  end

  describe "#specific_xkcd" do
    it "fails for invalid ids" do
      get :specific_xkcd, id: "derp"
      expect(response.body).to include("invalid id")
    end

    it "renders image tag for valid ids" do
      get :specific_xkcd, id: 123
      expect(response.body).to have_selector("img")
    end
  end

  it "renders json for single question" do
    q = FactoryGirl.create(:question)
    get :single_question, id: q.id
    expect { JSON.parse(response.body) }.not_to raise_error
  end

  it "handles mail delivery backend failure" do
    expect {
      UserMailer.stub_chain('feedback.deliver').and_return(false)
      post :feedback_send, name: user.nick, mail: user.mail, text: "derp"
    }.not_to change{ sent_mails.size }
    expect(flash[:error]).not_to be_nil
    expect(response).to render_template(:feedback)
  end

  it "allows feedback to be sent" do
    text = "omg, KeKs is down, help!"
    post :feedback_send, name: user.nick, text: text
    expect(flash[:success]).not_to be_nil
    expect(response).to redirect_to(:feedback)
    mail = ActionMailer::Base.deliveries.last
    expect(mail.body.encoded).to include(user.nick, text)
  end

  it "sends no mail when missing text" do
    expect {
      post :feedback_send, name: user.nick, mail: user.mail, text: ""
    }.not_to change{ sent_mails.size }
    expect(flash[:warning]).not_to be_nil
    expect(response).to render_template(:feedback)
    expect(response.body).to have_field(:name, with: user.nick)
    expect(response.body).to have_field(:mail, with: user.mail)
  end
end
