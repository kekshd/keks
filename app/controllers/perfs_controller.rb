# encoding: utf-8

class PerfsController < ApplicationController
  def create
    perf = Perf.new(params[:perf])
    perf.user_id = current_user_id

    ok = perf.save
    render text: ok ? "ok" : "fail"
  end
end
