# encoding: utf-8

module MainHelper
  def study_path_ids_from_param
    sp = params[:study_path]
    return [1] if !sp

    unless StudyPath.ids.include?(sp.to_i)
      logger.warn "Tried to access invalid study path id: #{sp}"
      return [1]
    end

    [1, sp.to_i].uniq
  end

  def difficulties_from_param
    diff = params[:difficulty].split("_").map(&:to_i) rescue []
    diff.reject! { |d| !Difficulty.ids.include?(d) }
    return diff if diff.any?

    return Difficulty.ids
  end
end
