# encoding: utf-8

class MainController < ApplicationController
  def overview
  end

  def hitme
  end

  def help
  end


  def questions
    cats = categories_from_param
    return render :json => {error: "No categories given"} if cats.empty?

    cnt = params[:count].to_i
    return render :json => {error: "No count given"} if cnt <= 0 || cnt > 100

    diff = difficulties_from_param
    sp = study_path_ids_from_param

    qs = []
    cats.each do |cat|
      qs << cat.questions.where(:difficulty => diff, :study_path => sp)
    end
    qs = qs.flatten.uniq

    reject_unsuitable_questions!(qs)
    qs = get_question_sample(qs, cnt)

    json = []
    json = qs.map { |q| json_for_question(q, 5) }

    render json: json
  end
end
