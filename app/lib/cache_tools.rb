# encoding: utf-8

def last_admin_or_reviewer_change
  t = Rails.cache.read_multi(
    :categories_last_update,
    :questions_last_update,
    :answers_last_update,
    :reviews_last_update,
    :hints_last_update
  )
  t.values.compact.max
end

def generate_cache_key(add = nil)
  c = if defined?(caller_locations)
    # Ruby 2.0+
    caller_locations(1,1)[0].label
  else
    # Ruby 1.9
    caller[0][/`([^']*)'/, 1]
  end

  [c, last_admin_or_reviewer_change, add].compact.join("__")
end
