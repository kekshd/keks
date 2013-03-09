# encoding: utf-8

class DotController < ApplicationController
  before_filter :require_admin

  def simple
    # the file should be served directly by Apache/nginx. If this path
    # is hit, it means the rendering as failed.
    redirect_to ActionController::Base.helpers.asset_path('broken.png')
  end
end
