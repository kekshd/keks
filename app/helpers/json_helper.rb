# encoding: utf-8

module JsonHelper

  def json_for_answer(a)
    @answer = a
    {
      correct: a.correct,
      subquestions: a,
      correctness: render_to_string(partial: '/answers/render_correctness'),
      id: a.id,
      html: render_to_string(partial: '/answers/render')
    }
  end

  def json_for_question(q)
    @question = q

    hints = []
    q.hints.each do |h|
      @hint = h
      hints << render_to_string(partial: '/hints/render')
    end

    answers = []
    q.answers.each { |a| answers << json_for_answer(a) }

    {
      'starred' => signed_in? ? current_user.starred.include?(q) : false,
      'hints' => hints,
      'answers' => answers,
      'matrix' => q.matrix_validate?,
      'matrix_solution' => q.matrix_solution,
      'id' => q.id,
      'html' => render_to_string(partial: '/questions/render')
    }
  end
end
