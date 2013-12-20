require "spec_helper"

describe MainHelper do
  describe "#study_path_ids_from_param" do
    it "ignores invalid study_path ids" do
      helper.stub!(:params).and_return { {study_path: 1293234732947329423} }
      expect(helper.study_path_ids_from_param).to eql([1])
    end
  end
end
