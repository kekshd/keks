# encoding: utf-8

module LatexHelper
  # be able to use tag helpers when called from controller
  include ActionView::Helpers::TagHelper

  # renders a few things not handled by MathJax, which does the
  # heavy TeX rendering client side. Namely, this function:
  # – inserts paragraphs (empty line → <br><br>)
  # – removes legacy § symbols
  # – it html-escapes the input
  # If wrapper is stet to true, the processed input is returned with a
  # wrapper div that indicates MathJax should render this.
  def render_tex(mixed, wrapper = true)
    return '' if mixed.blank?
    mixed = ERB::Util.h(mixed)

    mixed.gsub!('§', '')
    mixed.gsub!(/(\r\n){2,}|\n{2,}|\r{2,}/, '<br/><br/>')
    mixed = mixed.html_safe

    wrapper ? content_tag(:div, mixed, class: 'tex') : mixed
  end

  def latex_logo_large
    content_tag(:div, %|\\(\\Large\\LaTeX\\)|, class: 'tex', style: 'display: inline')
  end

  def latex_logo
    content_tag(:div, %|\\(\\LaTeX\\)|, class: 'tex', style: 'display: inline')
  end

  def short_matrix_str_to_tex(v)
    v = v.gsub("  ", '\\\\\\') # no idea why three are required.
    v = v.gsub(" ", " & ")
    "\\(\\begin{pmatrix} #{v} \\end{pmatrix}\\)"
  end

end
