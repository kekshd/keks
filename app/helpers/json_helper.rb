# encoding: utf-8

module JsonHelper

  def json_for_answer(a, max_depth)
    key = generate_cache_key(a.id)

    cache = Rails.cache.read(key)
    return cache if cache


    ajson = {
      correct: a.correct? ? 1 : 0,
      id: a.id,
      html: render_tex(a.text, false)
    }

    subq = get_subquestion_for_answer(a, max_depth)
    ajson[:subqestion] = subq if subq

    cacheable = max_depth > 0 && ajson[:subquestion].nil?
    Rails.cache.write(key, ajson) if cacheable

    ajson
  end

  def json_for_question(q, max_depth = 5)
    qkey = generate_cache_key(q.id)

    cache = Rails.cache.read(qkey)
    if cache
      if cache.is_a? Hash
        return cache
      else
        logger.error "Question-JSON was an array when it should have been a Hash. Invalidating #{q.id} // #{qkey}"
        logger.error PP.pp(cache, "")
        Rails.cache.delete(qkey)
      end
    end

    answers = []

    if max_depth > 0
      key = generate_cache_key("deep_resolve_#{q.id}")

      ans_qry = Rails.cache.fetch(key) {
        # the map forces rails to resolve
        q.answers.includes(:questions, :categories).map { |x| x }
      }
    else
      ans_qry = q.answers
    end

    ans_qry.each do |a|
      answers << json_for_answer(a, max_depth)
    end

    qjson = {
      answers:   answers,
      id:        q.id,
      html:      q.text
    }

    # only include these, if they evaluate to true to save bandwidth
    if q.matrix_validate?
      qjson[:matrix] = 1
      qjson[:matrix_solution] = q.matrix_solution
    end
    qjson[:starred] = 1 if signed_in? && current_user.has_starred?(q)
    qjson[:hints] = json_for_hints(q) if q.hints.any?

    # because subquestions are chosen randomly or roulette like, it’s
    # not possible to cache the question if there subquestions.
    cachable = max_depth > 0 && answers.all? { |a| a[:subquestion].nil? }
    Rails.cache.write(qkey, qjson) if cachable

    qjson
  end

  def json_for_hints(question)
    hints = []
    question.hints.each do |h|
      @hint = h
      hints << render_to_string(partial: '/hints/render')
    end
    hints
  end
end
