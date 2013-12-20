# encoding: utf-8

class MainController < ApplicationController
  include MainHelper
  include RandomSelectionHelper

  before_filter :def_etag, only: [:hitme, :help, :overview]

  def overview
    return redirect_to main_hitme_url + '#hide-options' if signed_in?
  end

  def hitme
  end

  def help
  end

  def feedback
    @text = params[:text]
    fresh_when(etag: etag(@text))
  end

  def feedback_send
    @name = params[:name]
    @mail = params[:mail]
    @text = params[:text]

    if @text.empty?
      flash[:warning] = "Ohne Text kein Feedback. Ohne Feedback KeKs schlecht. Gib uns Text, bitte!"
      return render :feedback
    end

    if UserMailer.feedback(@text, @name, @mail).deliver
      flash[:success] = "Mail ist raus, vielen Dank!"
      return redirect_to feedback_path
    else
      flash[:error] = "Das System ist kaputt. Kannst Du das bitte ganz klassisch an keks@uni-hd.de senden?"
      return render :feedback
    end
  end

  # renders json suitable for the hitme page containing only a single
  # question given
  def single_question
    render json: [json_for_question(Question.find(params[:id]))]
  end

  def random_xkcd
    url = nil
    err = nil
    begin
      open("http://dynamic.xkcd.com/random/comic/", redirect: false) do
        url = resp.base_uri
      end
    rescue OpenURI::HTTPRedirect => rdr
      url = rdr.uri.to_s
    rescue => e
      err = e.message
    ensure
      if url
        id = url.gsub(/[^0-9]/, "")
        return redirect_to specific_xkcd_path(id)
      end

      err = "Der XKCD Server ist gerade nicht erreichbar. Sorry. Details: (random)  #{err}"
      return render(status: 502, text: err)
    end
  end

  caches_page :specific_xkcd
  def specific_xkcd
    id = params[:id].gsub(/[^0-9]/, "")
    return render(status: 400, text: "invalid id") if id.blank?

    begin
      html = open("http://xkcd.com/#{id}/").read

      comic_only = Nokogiri::HTML(html).at_css("#comic").to_s
      comic_only.gsub!("http://", "https://")
      render :text => comic_only
    rescue => e
      # TODO: this will be cached and there are no sweepers to remove it
      render :text => "Der XKCD Server ist gerade nicht erreichbar. Sorry. Details: (specific) #{e.message}"
    end
  end


  def questions
    expires_now
    get_categories
    get_count

    question_ids = Question.where(
      :parent_type => "Category",
      :parent_id => @cats,
      :difficulty => difficulties_from_param,
      :released => true,
      :study_path => study_path_ids_from_param)
      .pluck(:id)

    qs = select_random(question_ids, @cnt)

    json = qs.map.with_index do |q, idx|
      # maximum depth of 5 questions. However, avoid going to deep for
      # later questions. For example, the last question never will
      # present a subquestion, regardless if it has one. Therefore, no
      # need to query for them.
      c = @cnt - idx - 1
      tmp = json_for_question(q, [c, 5].min)

      # assert the generated data looks reasonable, otherwise skip it
      unless tmp.is_a?(Hash)
        raise <<-ERR
          JSON for Question #{q.id} returned an array when it should be a Hash

          #{PP.pp(q, "")}
          ERR
      end

      tmp
    end

    render json: json
  end

  private
  def get_categories
    @cats = if params[:categories]
      params[:categories].split("_").map(&:to_i)
    else
      Category.root_categories.pluck(:id)
    end

    render :json => {error: "No categories given"} if @cats.empty?
  end

  def get_count
    @cnt = params[:count].to_i

    render :json => {error: "No count given"} if @cnt <= 0 || @cnt > 100
  end
end
