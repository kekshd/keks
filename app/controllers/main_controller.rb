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
    time = Time.now

    cats = if params[:categories]
      params[:categories].split("_").map { |c| c.to_i }
    else
      Category.root_categories.pluck(:id)
    end

    return render :json => {error: "No categories given"} if cats.empty?

    cnt = params[:count].to_i
    return render :json => {error: "No count given"} if cnt <= 0 || cnt > 100

    diff = difficulties_from_param
    sp = study_path_ids_from_param

    qry = Question.where(
      :parent_type => "Category",
      :parent_id => cats,
      :difficulty => diff,
      :released => true,
      :study_path => sp)
      .to_sql
      .sub('"questions".*', '"questions"."id"')

    question_ids = ActiveRecord::Base.connection.select_values(qry)

    ## comment in to only show matrix-questions
    #qs.reject!{ |q| !q.matrix_validate? }

    logger.info "### get question ids: #{(Time.now - time)*1000}ms"
    time = Time.now


    qs = get_question_sample(question_ids, cnt)

    logger.info "### find sample: #{(Time.now - time)*1000}ms"
    time = Time.now

    json = qs.map.with_index do |q, idx|
      # maximum depth of 5 questions. However, avoid going to deep for
      # later questions. For example, the last question never will
      # present a subquestion, regardless if it has one. Therefore, no
      # need to query for them.
      c = cnt - idx - 1
      tmp = json_for_question(q, c < 5 ? c : 5)

      # assert the generated data looks reasonable, otherwise skip it
      unless tmp.is_a?(Hash)
        msg = "JSON for Question #{q.id} returned an array when it should be a Hash\n\n#{PP.pp(q, "")}"
        if Rails.env.development?
          raise msg
        else
          logger.error msg
          next
        end
      end

      tmp
    end

    render json: json

    logger.info "### resolve: #{(Time.now - time)*1000}ms"
    time = Time.now
  end

  def random_xkcd
    begin
      render :text => open("http://dynamic.xkcd.com/random/comic/").read
    rescue
      render :text => "Der XKCD Server ist gerade nicht erreichbar. Sorry."
    end
  end
end
