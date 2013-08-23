# encoding: utf-8

class ApplicationController < ActionController::Base
  protect_from_forgery
  include ApplicationHelper
  include AnswersHelper
  include SessionsHelper
  include LatexHelper
  include DotHelper
  include JsonHelper

 before_filter :init
  def init
    @start_time = Time.now.usec
  end
end
