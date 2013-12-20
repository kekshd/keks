# encoding: utf-8

module ApplicationHelper
  def param_to_int_arr(ident)
    params[ident].split("_").map(&:to_i) rescue []
  end

  def bool_to_symbol(bool)
    bool ? "✔" : "✘"
  end

  def perc(perc, all, err_message)
    return err_message if all.nil? || all == 0
    perc ||= 0
    all ||= 0
    number_to_percentage(perc/all.to_f*100, :precision => 0)
  end

  def trace_to_root_formatter(str)
    str = h str
    str.gsub!("\0open\0", %|<span class="traceToRootSplitter">|)
    str.gsub!("\0newline\0", %|<br/>|)
    str.gsub!("\0close\0", %|</span>|)
    str = %|<span class="traceToRootLine">#{str}</span>|
    str.html_safe
  end

  def url_for(options = nil)
    if Hash === options && Rails.env.production?
      options[:protocol] = 'https:'
    end
    super(options)
  end

  def redirect_to(options = {}, response_status = {})
    return super(options, response_status) unless Rails.env.production?

    case options
    when String
      if options.start_with?('http://')
        options.sub!(/^http:/, 'https:')
      elsif options =~ /^\w+:\/\//i
      else
        options = request.protocol.sub('http', 'https') + request.host_with_port + options
      end
    when :back
    when Proc
    else
      o = options.merge({:protocol => 'https:'}) rescue options
      url_for(o).sub(/^http:/, 'https:')
    end

    super(options, response_status)
  end

  def etag(text = nil)
    # always bust browser cache in development mode so pages that can be
    # cached indefinitely in production mode get auto-reload support
    return Time.now.to_s if Rails.env.development?
    tag = []
    tag << GIT_REVISION if defined?(GIT_REVISION)
    tag << current_user.id if current_user
    tag << last_admin_or_reviewer_change
    tag << text unless text.blank?
    tag.join("_")
  end

  # retrieves question from URL parameters for all nested resources.
  # Usage: before_filter :get_question
  def get_question(redirect_on_error = questions_path)
    @question = Question.find(params[:question_id]) rescue nil
    unless @question
      flash[:warning] = "Frage mit dieser ID nicht gefunden."
      redirect_to redirect_on_error
    end
  end

  # for the given search hit, it returns the the field with all matches
  # highlighted. Optionally may specify to include whole stored text.
  # Via https://github.com/sunspot/sunspot/issues/111
  def search_highlight(search_hit, field, everything = false)
    phrases = []
    snippets = []

    search_hit.highlights(field).each do |highlight|
      phrases << highlight.instance_eval { @highlight }.scan(/@@@hl@@@([^@]+)@@@endhl@@@/)
      snippets << highlight.format { |w| w } unless everything
    end

    text = everything ? search_hit.stored(field).first : snippets.flatten.join

    highlight text, phrases.flatten
  end

  def search_snippet(search_hit, field, everything = false)
    t = search_highlight(search_hit, field, everything)
    return "" if t.blank?
    t = safe_join([content_tag(:span, field.to_s.humanize), t])
    content_tag(:div, t)
  end



  private


  # Counts how often each question has been answered by the given user
  # either correctly or incorrectly. Skipped questions are not taken
  # into account. Returns two hashes, the first with question_id to
  # times of correctly answered. The second is for wrong answers. Each
  # hash may omit question ids if the user never answered them.
  def answer_count_by_question_for(user)
    tmp = Stat.unscoped.where(:user_id => user.id, :skipped => false)
    correct = tmp.where(:correct => true).group(:question_id).size
    wrong = tmp.where(:correct => false).group(:question_id).size
    return correct, wrong
  end

  # calculates the correctly-answered-ratio for all given question IDs
  # and the given user. If a question was never answered, it gets a
  # ratio of 1. Every question receives at least a ratio of 0.1 to
  # prevent it from never appearing again after answering it correctly
  # once. Values thus range from 1.0 to 0.1. Higher values mean the
  # question has been answered wrong more often.
  def wrong_ratio_for(question_ids, user)
    # calculate ratio for each question how often it was answered in-
    # correctly by the user. Effectively, all the code does is:
    #   probs = questions.map { |q| [1 - q.correct_ratio_user(user), 0.1].max }
    # but a lot faster.
    correct, wrong = answer_count_by_question_for(user)

    question_ids.map do |qid|
      c = correct[qid] || 0
      w = wrong[qid] || 0
      cw = c+w
      [cw == 0 ? 1 : w/cw.to_f, 0.1].max
    end
  end
end
