# encoding: utf-8

module AnswersHelper
  def render_correctness(answer)
    c = answer.is_a?(Answer) ? answer.correct? : answer
    txt = c ? '✔ richtig' : '✘ falsch'
    cls = c ? 'success' : 'error'
   %|<em class="alert-#{cls}">#{txt}</em>|.html_safe
  end

end
