# encoding: utf-8

module JsonHelper

  def json_for_answer(a, max_depth)
    {
      correct: a.correct,
      subquestion: get_subquestion_for_answer(a, max_depth),
      correctness: render_correctness(a),
      id: a.id,
      html: render_to_string(partial: '/answers/render', locals: {answer: a})
    }
  end

  def json_for_question(q, max_depth = 5)
    hints = []
    q.hints.each do |h|
      @hint = h
      hints << render_to_string(partial: '/hints/render')
    end

    answers = []
    q.answers.includes(:questions, :categories).each { |a| answers << json_for_answer(a, max_depth) }

    {
      'starred' => signed_in? ? current_user.starred.include?(q) : false,
      'hints' => hints,
      'answers' => answers,
      'matrix' => q.matrix_validate?,
      'matrix_solution' => q.matrix_solution,
      'id' => q.id,
      'html' => render_to_string(partial: '/questions/render', locals: {question: q})
    }
  end
end
