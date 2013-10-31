# encoding: utf-8

module StatTools
  # returns the average amount of time taken per question answer for
  # the given stats. Includes skipped questions. Uses recent stats (30
  # days) by default, but you can pass others: time_taken(all_stats)
  def avg_time_taken(s = recent_stats)
    s.average(:time_taken).to_f
  end

  # returns the ratio of correct answers. Skipped ones are not counted.
  # Uses recent stats (30 days) by default. You can pass any other
  # stat association though: correct_ratio(all_stats) for example.
  def correct_ratio(s = recent_stats)
    all = s.where(:skipped => false).size.to_f
    all > 0 ? correct_count(s).to_f/all : 0
  end

  # calculates how often questions were skipped for the given stats.
  # Defaults to the stats created in the last 30 days. You can pass any
  # stats association though, e.g. skip_ratio(all_stats).
  def skip_ratio(s = recent_stats)
    all = s.size.to_f
    all > 0 ? skip_count(s).to_f/all : 0.0
  end

  def correct_count(s = recent_stats)
    s.where(:skipped => false, :correct => true).size
  end

  def skip_count(s = recent_stats)
    s.where(:skipped => true).size
  end

  # returns stats that are newer than the last 30 days.
  def recent_stats
    stats.where("stats.created_at > ?", 30.days.ago)
  end

  def all_stats
    stats.unscoped
  end
end
