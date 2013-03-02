# encoding: utf-8

class AdminController < ApplicationController
  before_filter :require_admin

  def overview
  end

end
