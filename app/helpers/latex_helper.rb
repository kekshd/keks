# encoding: utf-8

module LatexHelper
  def tex_to_path(tex)
    b = Base64.urlsafe_encode64(tex.strip)
    render_tex_path({:base64_text => b})
  end

  def tex_to_image_tag(tex, block = false)
    image_tag(tex_to_path(tex), alt: tex, class: block ? "latex-block" : "")
  end

  def render_tex(mixed)
    return '' if mixed.blank?
    imgs = []
    mixed.gsub!(/(§§?)([^§]+)\1/) do
      imgs << tex_to_image_tag($2, $1.size == 2)
      '§'
    end

    mixed = ERB::Util.h(mixed).gsub(/([\r\n]){2,}/, '<br/><br/>'.html_safe)

    mixed.gsub!('§') do
      imgs.shift
    end

    content_tag(:div, raw(mixed), class: 'tex')
  end

  def latex_logo_large
    tex_to_image_tag(%(\\textbf{\\Large\\LaTeX}))
  end

  def latex_logo
    tex_to_image_tag(%(\\textbf{\\Large\\LaTeX}))
  end
end
