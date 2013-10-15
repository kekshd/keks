# encoding: utf-8

require 'spec_helper'

describe DotController do
  let(:admin) { FactoryGirl.create(:admin) }


  it "renders broken.png for all hits that reach it" do
    sign_in admin
    get :simple, sha256: "asd"
    expect(response).to be_redirect
  end


end
