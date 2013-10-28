# encoding: utf-8

module AnswersHelper
  def render_correctness(answer)
    c = answer.correct?
    txt = answer.correct_text
    cls = c ? 'success' : 'error'
   %|<em class="alert-#{cls}">#{txt}</em>|.html_safe
  end

end
