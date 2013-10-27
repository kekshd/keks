# encoding: utf-8

require 'spec_helper'

describe LatexController do
  render_views

  describe "#complex" do
    it "handles nil gracefully" do
      post :complex, format: :text
      expect(response.body).to eql ""
    end

    it "renders tex" do
      post :complex, text: "\\LaTeX", format: :text
      expect(response.body).to include("\\LaTeX")
    end
  end
end
