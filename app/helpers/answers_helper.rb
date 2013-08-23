# encoding: utf-8

module AnswersHelper
  def render_correctness(answer)
    c = answer.correct?
    txt = c ? "✔ richtig" : "✘ falsch"
    cls = c ? 'success' : 'error'
   %|<em class="alert-#{cls}">#{txt}</em>|
  end

end
