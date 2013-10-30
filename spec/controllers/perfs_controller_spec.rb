# encoding: utf-8

require 'spec_helper'

describe PerfsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:perf) { FactoryGirl.build(:perf) }

  describe "#create" do
    it "stores perf data" do
      expect {
        post :create, perf: { agent: perf.agent, url: perf.url, load_time: perf.load_time }
      }.to change { Perf.count }.by(1)
    end

    it "stores user id" do
      sign_in user
      post :create, perf: { agent: perf.agent, url: perf.url, load_time: perf.load_time }
      expect(Perf.last.user_id).not_to eql -1
    end
  end
end
