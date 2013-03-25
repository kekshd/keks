JsRoutes.setup do |config|
  config.prefix = '/' + ENV['RAILS_RELATIVE_URL_ROOT'] if ENV['RAILS_RELATIVE_URL_ROOT']
end
