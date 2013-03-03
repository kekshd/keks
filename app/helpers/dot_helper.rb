# encoding: utf-8

module DotHelper
  def dot_to_path(dot)
    sha = Digest::SHA256.hexdigest(dot)
    render_dot_path({:sha256 => sha})
  end

  def dot_to_image_tag(dot)
    image_tag(dot_to_path(dot), alt: dot)
  end

  def render_dot(dot)
    dot = %(digraph graphname { #{dot} })

    sha = Digest::SHA256.hexdigest(dot)
    fn = File.join(Rails.public_path, "dot", sha + ".png")
    unless File.exist?(fn)
      begin
        FileUtils.mkdir_p File.dirname(fn)

        Open3.popen2(%(dot -Tpng > "#{fn}" || rm "#{fn}")) do |stdin, stdout|
          stdin.puts dot
          stdin.flush
          stdin.close
        end

      rescue => e
        logger.error("uncaught #{e} exception while rendering: #{e.message}")
        logger.error("Stack trace: #{e.backtrace.map {|l| "  #{l}\n"}.join}")
      end
    end

    dot_to_image_tag(dot)
  end
end
