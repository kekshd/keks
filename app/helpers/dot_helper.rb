# encoding: utf-8

module DotHelper
  def dot_to_path(dot)
    b = Base64.urlsafe_encode64(dot)
    render_dot_path({:base64_text => b})
  end

  def dot_to_image_tag(dot)
    image_tag(dot_to_path(dot), alt: dot)
  end

  def render_dot(dot)
    dot_to_image_tag(%(digraph graphname { #{dot} }))
  end
end
