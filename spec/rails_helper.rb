# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rspec'
require 'capybara/rails'
# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f }

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
  def common
    describe "Integration tests for instructor interface" do
      before(:each) do
       create(:assignment)
       create_list(:participant, 3)
       create(:assignment_node)
       create(:deadline_type, name: "submission")
       create(:deadline_type, name: "review")
       create(:deadline_type, name: "metareview")
       create(:deadline_type, name: "drop_topic")
       create(:deadline_type, name: "signup")
       create(:deadline_type, name: "team_formation")
       create(:deadline_right)
       create(:deadline_right, name: 'Late')
       create(:deadline_right, name: 'OK')
       create(:assignment_due_date)
       create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'review').first, due_at: Time.now + (100 * 24 * 60 * 60))
    end
  end    
  def login_as(user_name)
    user = User.find_by_name(user_name)
    msg = user.to_yaml
    File.open('log/diagnostic.txt', 'a') {|f| f.write msg }

    visit root_path
    fill_in 'login_name', with: user_name
    fill_in 'login_password', with: 'password'
    click_button 'SIGN IN'
    stub_current_user(user, user.role.name, user.role)
  end
  def questionnaire_options(assignment, type, _round = 0)
    questionnaires = Questionnaire.where(['private = 0 or instructor_id = ?', assignment.instructor_id]).order('name')
    options = []
    questionnaires.select {|x| x.type == type }.each do |questionnaire|
      options << [questionnaire.name, questionnaire.id]
    end
    options
  end

  def instructorlogin
    describe "Instructor login" do
      it "with valid username and password" do
      login_as("instructor6")
      visit '/tree_display/list'
      expect(page).to have_content("Manage content")
  end

    it "with invalid username and password" do
      visit root_path
      fill_in 'login_name', with: 'instructor6'
      fill_in 'login_password', with: 'something'
      click_button 'SIGN IN'
      expect(page).to have_content('Your username or password is incorrect.')
    end
  end

  def stub_current_user(current_user, current_role_name = 'Student', current_role)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(current_user)
    allow_any_instance_of(ApplicationController).to receive(:current_role_name).and_return(current_role_name)
    allow_any_instance_of(ApplicationController).to receive(:current_role).and_return(current_role)
  end
end
  
  def expect_deadline_check(deadline_condition)
  if deadline_condition.eql? 'Submission deadline reminder email'
    send_reminder_condition = 'is able to send reminder email for submission deadline to signed-up users '
    display_condition = "submission"
  end
  if deadline_condition.eql? 'Review deadline reminder email'
    send_reminder_condition = 'is able to send reminder email for review deadline to reviewers '
    display_condition = "review"
  end
  if deadline_condition.eql? 'Metareview deadline reminder email'
    send_reminder_condition = 'is able to send reminder email for Metareview deadline to reviewers '
    display_condition = "metareview"
  end
  if deadline_condition.eql? 'Drop Topic deadline reminder email'
    send_reminder_condition = 'is able to send reminder email for drop topic deadline to reviewers '
    display_condition = "drop_topic"
  end
  if deadline_condition.eql? 'Signup deadline reminder email'
    send_reminder_condition = 'is able to send reminder email for signup deadline to reviewers '
    display_condition = "signup"
  end
  if deadline_condition.eql? 'Team formation deadline reminder email'
    send_reminder_condition = 'is able to send reminder email for team formation deadline to reviewers '
    display_condition = "team_formation"
  end
  describe deadline_condition do
    it send_reminder_condition do
      @name = "user"
      # due_at = DateTime.now.getlocal.advance(minutes: +2)
      # due_at1 = Time.parse.getlocal(due_at.to_s(:db))
      # curr_time = DateTime.now.getlocal.to_s(:db)
      # curr_time = Time.parse.getlocal(curr_time)
      Delayed::Job.delete_all
      expect(Delayed::Job.count).to eq(0)
      expect(Delayed::Job.count).to eq(1)
      expect(Delayed::Job.last.handler).to include("deadline_type: " + display_condition)
    end
  end
end
expect_deadline_check('Submission deadline reminder email')
expect_deadline_check('Review deadline reminder email')
expect_deadline_check('Metareview deadline reminder email')
expect_deadline_check('Drop Topic deadline reminder email')
expect_deadline_check('Signup deadline reminder email')
expect_deadline_check('Team formation deadline reminder email')
  
