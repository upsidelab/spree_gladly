# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

require File.expand_path('../dummy/config/environment.rb', __FILE__)

require 'rspec/rails'
require 'ffaker'
require 'database_cleaner'
# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each { |f| require f }

require 'openssl'
require 'timecop'

# Requires factories and other useful helpers defined in spree_core.
require 'spree/testing_support/authorization_helpers'
require 'spree/testing_support/caching'
require 'spree/testing_support/controller_requests'
require 'spree/testing_support/factories'
require 'spree/testing_support/url_helpers'

RSpec.configure do |config|
  # Infer an example group's spec type from the file location.
  config.infer_spec_type_from_file_location!

  # == URL Helpers
  #
  # Allows access to Spree's routes in specs:
  #
  # visit spree.admin_path
  # current_path.should eql(spree.products_path)
  config.include Spree::TestingSupport::UrlHelpers

  # == Requests support
  #
  # Adds convenient methods to request Spree's controllers
  # spree_get :index
  config.include Spree::TestingSupport::ControllerRequests, type: :controller

  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec do |mocks|
    mocks.allow_message_expectations_on_nil = false
    mocks.verify_doubled_constant_names     = true
    mocks.verify_partial_doubles            = true
  end

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # Capybara javascript drivers require transactional fixtures set to false, and we use DatabaseCleaner
  # to cleanup after each test instead.  Without transactional fixtures set to false the records created
  # to setup a test will be unavailable to the browser, which runs under a separate server instance.
  config.use_transactional_fixtures = false
  config.color                      = true
  config.raise_on_warning           = true
  config.order                      = 'random'
  config.default_formatter          = 'doc'
  config.fail_fast                  = ENV['FAIL_FAST'] || false


  config.before do
    Rails.cache.clear
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
