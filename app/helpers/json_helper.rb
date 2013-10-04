# encoding: utf-8

module JsonHelper

  def json_for_answer(a, max_depth)
    key = ["json_for_answer"]
    key << last_admin_or_reviewer_change
    key << a.id
    key = key.join("__")

    cache = Rails.cache.read(key)
    return cache if cache


    ajson = {
      correct: a.correct,
      subquestion: get_subquestion_for_answer(a, max_depth),
      correctness: render_correctness(a),
      id: a.id,
      html: render_tex(a.text)
    }

    cacheable = max_depth > 0 && ajson[:subquestion].nil?
    Rails.cache.write(key, ajson) if cacheable

    ajson
  end

  def json_for_question(q, max_depth = 5)
    qkey = ["json_for_question"]
    qkey << last_admin_or_reviewer_change
    qkey << q.id
    qkey = qkey.join("__")

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


    hints = []
    q.hints.each do |h|
      @hint = h
      hints << render_to_string(partial: '/hints/render')
    end

    answers = []


    if max_depth > 0
      key = ["question_deep_answers_resolve"]
      key << last_admin_or_reviewer_change
      key << q.id
      key = key.join("__")

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
      starred:   signed_in? ? current_user.has_starred?(q) : false,
      hints:     hints,
      answers:   answers,
      matrix:    q.matrix_validate?,
      matrix_solution: q.matrix_solution,
      id:        q.id,
      html:      render_to_string(partial: '/questions/render', locals: {question: q})
    }

    # because subquestions are chosen randomly or roulette like, it’s
    # not possible to cache the question if there any subquestion.
    cachable = max_depth > 0 && answers.all? { |a| a[:subquestion].nil? }
    Rails.cache.write(qkey, qjson) if cachable

    qjson
  end
end
