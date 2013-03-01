# encoding: utf-8

class DotController < ApplicationController
  caches_page :simple, :gzip => false

  def simple
    begin
      dot = Base64.urlsafe_decode64(params[:base64_text])
      png = nil
      Open3.popen2("dot -Tpng") do |stdin, stdout|
        stdin.puts dot
        stdin.flush
        stdin.close
        png = stdout.read
      end
    rescue => e
      logger.error("uncaught #{e} exception while rendering: #{e.message}")
      logger.error("Stack trace: #{e.backtrace.map {|l| "  #{l}\n"}.join}")

      redirect_to ActionController::Base.helpers.asset_path('broken.png')
      return
    end

    send_data png, :type => 'image/png', :disposition => 'inline'
  end
end
