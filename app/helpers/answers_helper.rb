# encoding: utf-8

module AnswersHelper
  def markup_correct(answer)
    a = answer || @answer
    c = a.correct?
    txt = c ? "✔ richtig" : "✘ falsch"
    cls = c ? 'success' : 'error'
    content_tag(:em, txt, class: "alert-#{cls}")
  end


end
