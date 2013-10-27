# encoding: utf-8

require 'spec_helper'

describe TextStorageController do
  let(:reviewer) { FactoryGirl.create(:reviewer) }
  let(:admin) { FactoryGirl.create(:admin) }
  let(:ts) { FactoryGirl.create(:text_storage) }

  describe "#update" do
    def upd(ts)
      request.env["HTTP_REFERER"] = "http://test.host/whereever"
      put :update, id: ts.id, text_storage: { value: "new text" }
      ts.reload
    end

    it "dismisses reviewers" do
      sign_in reviewer
      expect {
        upd(ts)
      }.not_to change { ts.value }
    end

    it "updates stored text for admins" do
      sign_in admin
      upd(ts)
      expect(ts.value).to eql("new text")
    end

    it "returns you to previous location" do
      sign_in admin
      upd(ts)
      expect(response).to redirect_to(:back)
    end

    it "returns you to previous location even if given non-existing id" do
      sign_in admin
      request.env["HTTP_REFERER"] = "http://test.host/whereever"
      put :update, id: "does not exist", text_storage: { value: "new text" }
      expect(response).to redirect_to(:back)
    end
  end
end
