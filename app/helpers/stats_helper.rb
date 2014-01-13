# encoding: utf-8

module StatsHelper

  def raw_to_percentage(raw_data_array)
    size = raw_data_array[:right].size

    percent_correct = []
    percent_skipped = []
    # walk in reverse
    ((size-1).downto(0)).each do |i|
      r = raw_data_array[:right]
      w = raw_data_array[:wrong]
      s = raw_data_array[:skipped]
      rw = r[i] + w[i]
      rws = rw + s[i]
      percent_correct << (rw  == 0 ? -1 : (r[i] / rw.to_f)*100)
      percent_skipped << (rws == 0 ? -1 : (s[i] / rws.to_f)*100)
    end

    return percent_correct, percent_skipped
  end

  def insert_stat_in_hash(stat, hash, time = Time.now)
    # group by running week
    weeks_ago = weeks_ago(stat.created_at, time)
    return if hash[:right][weeks_ago].nil?
    if stat.skipped?
      hash[:skipped][weeks_ago] += 1
    else
      hash[stat.correct ? :right : :wrong][weeks_ago] += 1
    end
  end

  def weeks_ago(time, from = Time.now)
    (((from - time) / 1.day) % 7).to_i
  end

  def render_graph
    LazyHighCharts::HighChart.new('graph') do |f|
      graph_defaults(f)
      f.options[:plotOptions][:series] = {pointInterval: 7.days, pointStart: (91-7).days.ago}
      f.yAxis({title: {text: "Anteil in Prozent"}, min: 0, max: 100})
    end
  end


  def render_date_to_count_graph(name, date_to_count_hash, range)
    raise "date_to_count_hash must be a Hash" unless date_to_count_hash.is_a?(Hash)

    unless date_to_count_hash.size == 0 || date_to_count_hash.keys.first.is_a?(String)
      raise "date_to_count_hash key’s must be strings like this: “2013-11-23”"
    end

    ago = range.days.ago
    values = fill_missing(date_to_count_hash, 0, ago.to_date, Date.today)

    @h = LazyHighCharts::HighChart.new('graph') do |f|
      graph_defaults(f)
      f.options[:plotOptions][:series] = {pointInterval: 1.days, pointStart: ago}
      f.yAxis({title: {text: "Anzahl"}, min: 0, max: values.max })
    end

    @h.series(name: name, data: values)
    @h
  end

  private

  def fill_missing(hash, fill, from, to)
    from.upto(to).map { |e| hash[e.to_s] || fill }
  end

  def graph_defaults(graph)
    graph.options[:chart][:defaultSeriesType] = "line"
    graph.options[:chart] = { width: 850, height: 280 }
    graph.options[:tooltip][:enabled] = false
    graph.options[:plotOptions][:line] = {
      animation: false,
      enableMouseTracking: false,
      marker: { enabled: false }
    }
    graph.xAxis(type: :datetime, dateTimeLabelFormats: { day: '%e. %b' })
  end
end
