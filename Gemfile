source 'https://rubygems.org'

gem 'rails',                '3.2.19'
gem 'sqlite3'
gem 'thin'
gem 'active_enum',          '0.9.12'
gem 'nokogiri'
gem 'will_paginate'

# nested eager loading through polymorphic associations
gem 'activerecord_lax_includes', :git => 'https://github.com/unixcharles/active-record-lax-includes.git'

# javascript
gem 'magnific-popup-rails'
gem 'jquery-rails',         '2.2.1'
gem 'jquery-tablesorter',   '1.4.1'
gem 'js-routes',            '0.8.7'
gem 'lazy_high_charts',     '1.4.0'

# To use ActiveModel has_secure_password
gem 'bcrypt-ruby',          '~> 3.0.0'

# searching
gem 'sunspot_rails'
gem 'sunspot_solr',                       require: false

group :development do
  gem 'pry-rails'
  gem 'awesome_print'       # console highlighting
  gem 'bullet'              # detect n+1 queries
  gem 'better_errors'       # improve in browser error messages
  gem 'binding_of_caller'   # allow to spawn a REPL for above
  gem 'letter_opener'       # preview mails in browser rather than using an actual smtp
  gem 'meta_request'        # show log in Chrome dev tools with RailsPanel addon

  gem 'guard'
  # automatically reload web pages. rack- handles the browser part and
  # guard-* listens to changes on the file systen.
  gem 'rack-livereload'
  gem 'guard-livereload',                 require: false

  gem 'guard-zeus'          # run zeus when starting guard
  gem 'guard-bundler'       # auto install/update gems
  gem 'guard-sunspot'       # handle solr search engine

  # loaded in development mode, so it is picked up by zeus
  gem 'parallel_tests'
end

group :test do
  gem 'rspec-rails',        '2.13.0'
  gem 'rspec-instafail',                  require: false
  gem 'teaspoon'            # js unit test

  gem 'factory_girl_rails', '4.2.0'
  gem 'capybara',           '2.1.0'
  gem 'capybara-webkit'
  gem 'faker',              '1.1.2'

  gem 'zeus',                             require: false
  gem 'zeus-parallel_tests',              require: false

  gem 'simplecov',          '0.8.0.pre2', require: false
  gem 'coveralls',                        require: false
end

group :assets do
  gem 'turbo-sprockets-rails3'
  gem 'sass-rails',         '3.2.6'
  gem 'uglifier',           '1.3.0'
  gem 'therubyracer'
end
