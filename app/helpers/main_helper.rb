# encoding: utf-8

module MainHelper
  def parse_params
    parse_count
    parse_categories
    parse_study_path
    parse_difficulty
  end

  def parse_categories
    params[:categories] = if params[:categories]
      params[:categories].split("_").map(&:to_i)
    else
      Category.root_categories.pluck(:id)
    end

    render :json => {error: "No categories given"} if params[:categories].empty?
  end

  def parse_count
    params[:count] = cnt = params[:count].to_i

    render :json => {error: "No count given"} if cnt <= 0 || cnt > 100
  end


  def parse_study_path
    sp = param_to_int_arr(:study_path).first
    sp = [1] if sp.nil? || !StudyPath.ids.include?(sp)
    params[:study_path] = [1, sp].uniq
  end

  def parse_difficulty
    params[:difficulty] = param_to_int_arr(:difficulty) & Difficulty.ids
    params[:difficulty] = Difficulty.ids if params[:difficulty].empty?
  end
end
