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
    mixed = mixed.dup # don’t change original string
    imgs = []
    mixed.gsub!(/(§§?)([^§]+)\1/) do
      delims, content = $1, $2
      # special mode if it’s only emphasized text.
      if content =~ /^\s*\\emph\{[a-z0-9\s.-]+\}\s*$/i
        imgs << content#.sub("\\emph{", "<em>").sub("}", "</em>")
      else
        imgs << content#tex_to_image_tag(content, delims.size == 2)
      end
      '§'
    end

    mixed = ERB::Util.h(mixed).gsub(/(\r\n){2,}|\n{2,}|\r{2,}/, '<br/><br/>'.html_safe)

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
