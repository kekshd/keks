class QuestionReachability
  def initialize(questions)
    @qq = [questions].flatten
  end

  # optionally require that the questions have one of the given
  # difficulties
  def require_difficulties(difficulties)
    @diffs = [difficulties].flatten.compact
    raise "difficulties must be integer" unless @diffs.all? { |d| d.is_a?(Integer) }
  end

  # optionally require that the questions belong to one of the given
  # study paths
  def require_study_paths(study_paths)
    @studies = [study_paths].flatten.compact
    raise "study paths must be integer" unless @studies.all? { |s| s.is_a?(Integer) }
  end

  def require_per_params(params)
    require_difficulties(params[:difficulty])
    require_study_paths(params[:study_path])
  end

  # returns false if none of the given questions are reachable
  def any_reachable?
    @qq.any? { |q| reachable?(q) }
  end

  # retrieves all questions that were not pruned and are reachable
  def get_reachable
    @qq.select { |q| reachable?(q) }
  end

  # retrieves all questions that were not pruned (less expensive than
  # reachable)
  def get_non_pruned
    @qq.select { |q| !pruned?(q) }
  end

  private

  # returns false if the direct parent element has an incompatible study
  # path to ours. I.e. returns false if this question is unreachable due
  # to study path mismatches.
  # Will also return false if the question does not fulfill the required
  # study paths or difficulties.
  def reachable?(q)
    return false unless q
    return false if pruned?(q)
    return false if conflicting_paths?(q)
    true
  end

  def pruned?(q)
    return true unless valid_study_path?(q)
    return true unless valid_difficulty?(q)
    false
  end


  def valid_study_path?(q)
    @studies.nil? || @studies.include?(q.study_path)
  end

  def valid_difficulty?(q)
    @diffs.nil? || @diffs.include?(q.difficulty)
  end

  def conflicting_paths?(q)
    # skip checks if this question is valid for all study paths
    return false if q.study_path == 1
    # categories don’t have a study path. If the category is not a root
    # one, it is be possible to create unreachable questions like this:
    # RootCat → Q w/ study path 1 → Cat → Q w/ study path 2
    # This isn’t checked as a speed trade off: it would require tracing
    # every possible way to root and checking each for study paths.
    return false if q.parent_type != "Answer"
    psp = q.parent.question.study_path
    psp != q.study_path && psp != 1
  end
end
