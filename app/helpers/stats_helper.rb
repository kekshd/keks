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
    weeks_ago = (((time - stat.created_at) / 1.day) % 7).to_i
    return if hash[:right][weeks_ago].nil?
    hash[:skipped][weeks_ago] += 1 if stat.skipped?
    hash[:right][weeks_ago] += 1 if !stat.skipped? && stat.correct
    hash[:wrong][weeks_ago] += 1 if !stat.skipped? && !stat.correct
  end


  def render_graph
    LazyHighCharts::HighChart.new('graph') do |f|

      f.options[:legend][:align] = 'right'
      f.options[:legend][:verticalAlign] = 'top'
      f.options[:chart][:defaultSeriesType] = "line"
      f.options[:chart][:width] = 700
      f.options[:chart][:height] = 280
      f.options[:tooltip][:enabled] = false
      f.options[:plotOptions][:series] = {pointInterval: 7.days, pointStart: (91-7).days.ago}
      f.options[:plotOptions][:line] = {animation: false}
      f.xAxis(type: :datetime, dateTimeLabelFormats: { day: '%e. %b' })
      f.yAxis({title: {text: "Anteil in Prozent"}, min: 0, max: 100})
    end
  end


  def render_date_to_count_graph(name, date_to_count_hash, range)
    raise "date_to_count_hash must be a Hash" unless date_to_count_hash.is_a?(Hash)

    unless date_to_count_hash.size == 0 || date_to_count_hash.keys.first.is_a?(String)
      raise "date_to_count_hash key’s must be strings like this: “2013-11-23”"
    end

    range.days.ago.to_date.upto(Date.today).each { |x| date_to_count_hash[x.to_s] ||= 0 }

    @h = LazyHighCharts::HighChart.new('graph') do |f|
      f.options[:legend][:align] = 'right'
      f.options[:legend][:verticalAlign] = 'top'
      f.options[:chart][:defaultSeriesType] = "line"
      f.options[:chart][:width] = 700
      f.options[:chart][:height] = 280
      f.options[:tooltip][:enabled] = false
      f.options[:plotOptions][:series] = {pointInterval: 1.days, pointStart:  @range.days.ago}
      f.options[:plotOptions][:line] = {animation: false}
      f.xAxis(type: :datetime, dateTimeLabelFormats: { day: '%e. %b' })
      f.yAxis({title: {text: "Anzahl"}, min: 0, max: date_to_count_hash.values.max })
    end

    @h.series(name: name, data: date_to_count_hash.values)
    @h
  end
end
