if ENV["COVERAGE"]
  require 'simplecov'
  SimpleCov.start 'rails' do
    add_filter 'vendor'
  end
end

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] = 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  #~　config.order = "random"

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end


  config.before do
    Capybara.current_driver = :webkit
    Capybara.javascript_driver = :webkit

    # comment this in to see live action testing in firefox. IRB testing
    # is likely the better choice though:
    # http://tom-clements.com/blog/2012/02/25/capybara-on-the-command-line-live-browser-testing-from-irb/

    #~ Capybara.current_driver = :selenium
    #~ Capybara.javascript_driver = :selenium
  end

  config.include RSpec::Rails::RequestExampleGroup, type: :feature
end

def wait_for_ajax(page)
  # firefox driver needs this
  #~　page.driver.options[:resynchronize] = true if page.driver.respond_to?(:options)
end
