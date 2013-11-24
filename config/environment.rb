# Load the rails application
require File.expand_path('../application', __FILE__)

def last_admin_or_reviewer_change
  t = Rails.cache.read_multi(
    :categories_last_update,
    :questions_last_update,
    :answers_last_update,
    :reviews_last_update,
    :hints_last_update
  )
  t.values.max
end


# Initialize the rails application
Keks::Application.initialize!
