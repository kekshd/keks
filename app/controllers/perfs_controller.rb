# encoding: utf-8

class PerfsController < ApplicationController
  def create
    perf = Perf.new(params[:perf])
    perf.user_id = signed_in? ? current_user.id : -1

    ok = perf.save
    render text: ok ? "ok" : "fail"
  end
end
