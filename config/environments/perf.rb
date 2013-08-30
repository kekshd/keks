# encoding: utf-8

Keks::Application.configure do
  config.whiny_nils = true
  config.cache_classes = true
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = true
  config.action_mailer.raise_delivery_errors = false
  config.active_support.deprecation = :notify
  config.log_level = :warn
  config.assets.compress = false
  config.action_mailer.default_url_options = { :host => "localhost:3000" }
end
