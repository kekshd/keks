# encoding: utf-8

class DotController < ApplicationController
  before_filter :require_admin

  #~ caches_action :simple, :cache_path => Proc.new { |c| c.request.url }

  def simple
    # file should be served by apache, seems broken?
    redirect_to ActionController::Base.helpers.asset_path('broken.png')

    #~ send_data png, :type => 'image/png', :disposition => 'inline'
  end
end
