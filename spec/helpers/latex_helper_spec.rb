require "spec_helper"

describe LatexHelper do
  describe "#latex_logo" do
    it "contains \\LaTeX" do
      expect(helper.latex_logo).to include("\\LaTeX")
    end
  end

  describe "#latex_logo_large" do
    it "contains \\LaTeX" do
      expect(helper.latex_logo).to include("\\LaTeX")
    end
  end

  describe "#short_matrix_str_to_tex" do
    it "includes right amount of rows and columns" do
      m = "1 2  3 4" # i.e. 2x2 matrix
      h = short_matrix_str_to_tex(m)
      expect(h).to include("pmatrix")
      expect(h.count("&")).to eql 2
      expect(h.scan('\\\\').count).to eql 1
    end
  end
end
