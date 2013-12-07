# encoding: utf-8

class AnswersController < ApplicationController
  before_filter :require_admin
  before_filter :get_question

  include DefaultActionsHelper
end
