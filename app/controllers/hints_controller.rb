# encoding: utf-8

class HintsController < ApplicationController
  before_filter :require_admin
  before_filter :get_question

  include DefaultActionsHelper
end
