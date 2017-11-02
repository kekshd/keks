class Api::V1::QuestionsController < Api::V1::BaseController
  def show
    @qs = Question.includes(:answers).find(params[:id])

    render json: @qs.as_json(:only => [:text], include: { answers: {:only => [:text, :correct]}})
  end
end
