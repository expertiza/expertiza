# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
require File.expand_path('../config/environment', __dir__)
require 'rspec/rails'
require 'capybara/rspec'
require 'capybara/rails'
require 'shoulda-matchers'

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end
  config.before(:each) do |_example|
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  def login_as(user_name)
    user = User.find_by(name: user_name)
    msg = user.to_yaml
    File.open('log/diagnostic.txt', 'a') { |f| f.write msg }

    visit root_path
    fill_in 'login_name', with: user_name
    fill_in 'login_password', with: 'password'
    click_button 'Sign in'
    stub_current_user(user, user.role.name, user.role)
  end

  def login_as_other_user(user_name)
    # user =  User.find_by(name: user_name)
    login_as(user_name)
    click_link 'Home'
    end

  def logout
    click_link 'Logout'
  end

  def stub_current_user(current_user, current_role_name = 'Student', current_role)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(current_user) if defined?(session)
    allow_any_instance_of(ApplicationController).to receive(:current_role_name).and_return(current_role_name)
    allow_any_instance_of(ApplicationController).to receive(:current_role).and_return(current_role)
    # Also pop this stub user into the session to support the authorization helper

    # Check if session is defined to differentiate between controller and non-controller tests.
    # This is required as the session variable is only defined for controller specs.
    # Other kinds of specs(feature specs,etc) use an internal rack.session that cannot be interacted with.
    session[:user] = current_user if defined?(session)
  end

  def http_status_factory(status_code)
    if status_code == 200
      Net::HTTPSuccess.new(1.0, 200, 'OK')
    elsif status_code == 500
      Net::HTTPServerError.new(1.0, 500, 'Internal Server Error')
    else
      raise ArgumentError
    end
  end

  def http_mock_wrap_text(text)
    '<head></head><body>' + text + '</body>'
  end

  def http_mock_success_text(add_html)
    text = 'Success'
    if add_html
      http_mock_wrap_text(text)
    else
      text
    end
  end

  def http_mock_error_text(add_html)
    text = 'Error'
    if add_html
      http_mock_wrap_text(text)
    else
      text
    end
  end

  # Attempts to parameterize this function failed
  def http_setup_get_request_mock_success
    class << HttpRequest
      define_method(:get) do |_url|
        res = http_status_factory(200)
        def res.body
          http_mock_success_text(true)
        end
        res
      end
    end
  end

  # Attempts to parameterize this function failed
  def http_setup_get_request_mock_error
    class << HttpRequest
      define_method(:get) do |_url|
        res = http_status_factory(500)
        def res.body
          http_mock_error_text(false)
        end
        res
      end
    end
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
