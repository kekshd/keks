# encoding: utf-8

class LatexController < ApplicationController
  def complex
    if params['text']
      @text = params['text']
      render 'complex'
    else
      render :text => ""
    end
  end
end
