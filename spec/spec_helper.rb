if ENV["COVERAGE"]
  require 'simplecov'

  if ENV["COVERALLS"]
    require 'coveralls'
    SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
      SimpleCov::Formatter::HTMLFormatter,
      Coveralls::SimpleCov::Formatter
    ]
  end

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
  config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  #~　config.order = "random"

  config.before do
    Capybara.current_driver = :webkit
    Capybara.javascript_driver = :webkit
    Capybara.server_port = 9887 + ENV['TEST_ENV_NUMBER'].to_i

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



# Better alternative to database cleaner, see
# http://blog.plataformatec.com.br/tag/capybara/
class ActiveRecord::Base
  mattr_accessor :shared_connection
  @@shared_connection = nil

  def self.connection
    @@shared_connection || retrieve_connection
  end
end

# Forces all threads to share the same connection. This works on
# Capybara because it starts the web server in a thread.
ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection
