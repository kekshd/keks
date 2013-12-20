require "spec_helper"

describe ApplicationHelper do
  describe "#perc" do
    it "returns percentage when given valid numbers" do
      expect(helper.perc(1, 3, "not used")).to eql "33%"
    end

    it "returns error message when all is 0" do
      expect(helper.perc(1, 0, "invalid data")).to eql "invalid data"
    end
  end

  #~　describe "#get_subquestion_for_answer" do
    #~　it "includes valid subquestion" do
      #~　a = FactoryGirl.create(:answer_with_subquestion)
      #~　q = a.get_all_subquestions.first
      #~　helper.stub(:difficulties_from_param) { [q.difficulty] }
      #~　helper.stub(:study_path_ids_from_param) { [q.study_path] }
      #~　helper.stub(:json_for_question) { q.text }
      #~　r = helper.get_subquestion_for_answer(a, 1)
      #~　expect(r).to include(q.text)
    #~　end
  #~　end
end
