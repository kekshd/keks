source 'https://rubygems.org'

gem 'rails',                '3.2.14'
gem 'sqlite3',              '1.3.7'
gem 'thin',                 '1.5.0'
gem 'active_enum',          '0.9.12'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'turbo-sprockets-rails3'
  gem 'sass-rails',         '3.2.6'
  gem 'coffee-rails',       '3.2.2'
  gem 'uglifier',           '1.3.0'
  gem 'therubyracer'
end

# javascript
gem 'jquery-rails',         '2.2.1'
gem 'jquery-tablesorter',   '1.4.1'
gem 'js-routes',            '0.8.7'
gem 'lazy_high_charts',     '1.4.0'

# To use ActiveModel has_secure_password
gem 'bcrypt-ruby',          '3.0.1'

# detect n+1 queries
gem 'bullet'

group :development do
  gem 'pry-rails',          '0.3.2'
  gem 'rack-livereload'     # automatically update pages in browser
  gem 'awesome_print'       # console highlighting
  gem 'better_errors'       # improve in browser error messages
  gem 'binding_of_caller'   # allow to spawn a REPL for above
  gem 'letter_opener'       # preview mails in browser rather than using an actual smtp
end

group :development, :test do
  gem 'database_cleaner',   '0.9.1'
  gem 'factory_girl_rails', '4.2.0'
  gem 'rspec-rails',        '2.13.0'
  gem 'time_bandits'        # improved logging of execution time
  gem 'zeus', :require => false
end

group :test do
  gem 'capybara',           '2.1.0'
  gem 'faker',              '1.1.2'
  # show rspec error message immediately when it fails
  gem 'rspec-instafail',    :require => false

  gem 'launchy',            '2.2.0'
  gem 'capybara-webkit'
  gem 'selenium-webdriver'
  gem 'simplecov',          '0.8.0.pre2', :require => false

  gem 'coveralls',                        :require => false
end
