# encoding: utf-8

class LatexController < ApplicationController

  caches_page :simple, :gzip => false


  def simple
    @text = Base64.urlsafe_decode64(params[:base64_text])
    #~ @text = params[:text]
    if @text.blank?
      redirect_to ActionController::Base.helpers.asset_path('empty.png')
      return
    end

    begin
      pdf = render_to_string(:template => "latex/simple.pdf", :layout => true)
      png = nil
      Open3.popen2("gs -q -dMaxBitmap=2147483647 -dQUIET -dSAFER -dBATCH -dNOPAUSE -sDEVICE=pngalpha -dAlignToPixels=0 -dGraphicsAlphaBits=4 -dTextAlphaBits=4 -r118 -sOutputFile=- -") do |stdin, stdout|
      #~ Open3.popen2("gs -q -dMaxBitmap=2147483647 -dQUIET -dSAFER -dBATCH -dNOPAUSE -sDEVICE=png16m -dAlignToPixels=0 -dGraphicsAlphaBits=4 -dTextAlphaBits=4  -r472 -dDownScaleFactor=4 -sOutputFile=- -") do |stdin, stdout|
        stdin.puts pdf
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

  def complex
    if params['text'] && params['text'].size < 100000
      @text = params['text']
      render 'complex'
    else
      render :text => "Kein Text oder Text zu lang"
    end
  end
end
