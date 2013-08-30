# encoding: utf-8

class MainController < ApplicationController
  def overview
    return redirect_to main_hitme_url + '#hide-options' if signed_in?
  end

  def hitme
  end

  def help
  end

  def feedback
    @text = params[:text]
  end

  def feedback_send
    if params[:text].empty?
      flash[:warning] = "Ohne Text kein Feedback. Ohne Feedback KeKs schlecht. Gib uns Text, bitte!"
      return render "feedback"
    end

    @name = params[:name]
    @mail = params[:mail]
    @text = params[:text]

    if UserMailer.feedback(@text, @name, @mail).deliver
      flash[:success] = "Mail ist raus, vielen Dank!"
      return redirect_to feedback_path
    else
      flash[:error] = "Das System ist kaputt. Kannst Du das bitte ganz klassisch an keks@uni-hd.de senden?"
      return render "feedback"
    end
  end

  # renders json suitable for the hitme page containing only a single
  # question given
  def single_question
    render json: [json_for_question(Question.find(params[:id]))]
  end

  def questions
    cats = params[:categories].split("_").map { |c| c.to_i }
    return render :json => {error: "No categories given"} if cats.empty?

    cnt = params[:count].to_i
    return render :json => {error: "No count given"} if cnt <= 0 || cnt > 100

    diff = difficulties_from_param
    sp = study_path_ids_from_param

    question_ids = Question.where(
      :parent_type => "Category",
      :parent_id => cats,
      :difficulty => diff,
      :released => true,
      :study_path => sp)
      .pluck(:id)

    ## comment in to only show matrix-questions
    #qs.reject!{ |q| !q.matrix_validate? }

    qs = get_question_sample(question_ids, cnt)

    json = qs.map.with_index do |q, idx|
      # maximum depth of 5 questions. However, avoid going to deep for
      # later questions. For example, the last question never will
      # present a subquestion, regardless if it has one. Therefore, no
      # need to query for them.
      c = cnt - idx - 1
      json_for_question(q, c < 5 ? c : 5)
    end

    render json: json
  end

  def random_xkcd
    begin
      render :text => open("http://dynamic.xkcd.com/random/comic/").read
    rescue
      render :text => "Der XKCD Server ist gerade nicht erreichbar. Sorry."
    end
  end
end
