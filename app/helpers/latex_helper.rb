# encoding: utf-8

module LatexHelper
  # legacy handler that removes now superfluous §-syntax
  def render_tex(mixed)
    return '' if mixed.blank?
    mixed = mixed.dup # don’t change original string
    imgs = []
    mixed.gsub!(/(§§?)([^§]+)\1/) do
      delims, content = $1, $2
      imgs << content
      '§'
    end

    mixed = ERB::Util.h(mixed).gsub(/(\r\n){2,}|\n{2,}|\r{2,}/, '<br/><br/>'.html_safe)

    mixed.gsub!('§') do
      imgs.shift
    end

    content_tag(:div, raw(mixed), class: 'tex')
  end

  def latex_logo_large
    content_tag(:div, %|\\(\\Large\\LaTeX\\)|, class: 'tex', style: 'display: inline')
  end

  def latex_logo
    content_tag(:div, %|\\(\\LaTeX\\)|, class: 'tex', style: 'display: inline')
  end
end
