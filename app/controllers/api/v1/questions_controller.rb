class Api::V1::QuestionsController < Api::V1::BaseController
  def show
    qs = Question.find(params[:id])

    render(json: Api::V1::QuestionSerializer.new(qs).to_json)
  end
end
