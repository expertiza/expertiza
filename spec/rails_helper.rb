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
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

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
   config.before(:each) do |example|
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
    user = User.find_by_name(user_name)

    visit root_path
    fill_in 'login_name', with: user_name
    fill_in 'login_password', with: 'password'
    click_button 'SIGN IN'
    stub_current_user(user, user.role.name, user.role)
  end

  def stub_current_user(current_user, current_role_name='Student', current_role)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(current_user)
    allow_any_instance_of(ApplicationController).to receive(:current_role_name).and_return(current_role_name)
    allow_any_instance_of(ApplicationController).to receive(:current_role).and_return(current_role)
  end
 def questionnaire_options(assignment, type, round=0)
    questionnaires = Questionnaire.where( ['private = 0 or instructor_id = ?', assignment.instructor_id]).order('name')
    options = Array.new
    questionnaires.select { |x| x.type == type }.each do |questionnaire|
      options << [questionnaire.name, questionnaire.id]
    end
    options
  end

  def choose_a_field(tablerow, selfield)
    @assignment_form = AssignmentForm.create_form_object('1')
    if tablerow == 'review'
      if selfield == 'questionnaire'
        find(:xpath, "//*[@id='questionnaire_table_ReviewQuestionnaire']//select[@name='assignment_form[assignment_questionnaire][][questionnaire_id]']").
            find(:option, (get_option)[0][1]).click
      end
      if selfield == 'usedropdown'
        find(:xpath, "//*[@id='questionnaire_table_ReviewQuestionnaire']//input[@id='dropdown']").click
      end
      if selfield == 'scored_question'
        find(:xpath, "//*[@id='questionnaire_table_ReviewQuestionnaire']//select[@id='scored_question_display_type']").
            find(:option, 'Scale').click
      end
      if selfield == 'Weight'
        find(:xpath, "//*[@id='questionnaire_table_ReviewQuestionnaire']//input[@name='assignment_form[assignment_questionnaire][][questionnaire_weight]']").set('50')
      end
      if selfield == 'notify_limit'
        find(:xpath, "//*[@id='questionnaire_table_ReviewQuestionnaire']//input[@name='assignment_form[assignment_questionnaire][][notification_limit]']").set('30')
      end
    end
    if tablerow == 'author feedback'
      if selfield == 'questionnaire'
        find(:xpath, "//*[@id='questionnaire_table_AuthorFeedbackQuestionnaire']//select[@name='assignment_form[assignment_questionnaire][][questionnaire_id]']").
            find(:option, (get_option)[0][1]).click
      end
      if selfield == 'usedropdown'
        find(:xpath, "//*[@id='questionnaire_table_AuthorFeedbackQuestionnaire']//input[@id='dropdown']").click
      end
      if selfield == 'scored_question'
        find(:xpath, "//*[@id='questionnaire_table_AuthorFeedbackQuestionnaire']//select[@id='scored_question_display_type']").
            find(:option, 'Scale').click
      end
      if selfield == 'Weight'
        find(:xpath, "//*[@id='questionnaire_table_AuthorFeedbackQuestionnaire']//input[@name='assignment_form[assignment_questionnaire][][questionnaire_weight]']").set('50')
      end
      if selfield == 'notify_limit'
        find(:xpath, "//*[@id='questionnaire_table_AuthorFeedbackQuestionnaire']//input[@name='assignment_form[assignment_questionnaire][][notification_limit]']").set('30')
      end
    end
    if tablerow == 'teammate review'
      if selfield == 'questionnaire'
        find(:xpath, "//*[@id='questionnaire_table_TeammateReviewQuestionnaire']//select[@name='assignment_form[assignment_questionnaire][][questionnaire_id]']").
            find(:option, (get_option)[0][1]).click
      end
      if selfield == 'usedropdown'
        find(:xpath, "//*[@id='questionnaire_table_TeammateReviewQuestionnaire']//input[@id='dropdown']").click
      end
      if selfield == 'scored_question'
        find(:xpath, "//*[@id='questionnaire_table_TeammateReviewQuestionnaire']//select[@id='scored_question_display_type']").
            find(:option, 'Scale').click
      end
      if selfield == 'Weight'
        find(:xpath, "//*[@id='questionnaire_table_TeammateReviewQuestionnaire']//input[@name='assignment_form[assignment_questionnaire][][questionnaire_weight]']").set('50')
      end
      if selfield == 'notify_limit'
        find(:xpath, "//*[@id='questionnaire_table_TeammateReviewQuestionnaire']//input[@name='assignment_form[assignment_questionnaire][][notification_limit]']").set('30')
      end
    end
  end

  def get_option
    questionnaire_options(@assignment_form.assignment, 'ReviewQuestionnaire').to_json.html_safe
  end

  def questionnaire(assignment, type, round_number)
    #E1450 changes
    if round_number.nil?
      questionnaire=assignment.questionnaires.find_by_type(type)
    else
      ass_ques=assignment.assignment_questionnaires.find_by_used_in_round(round_number)
      # make sure the assignment_questionnaire record is not empty
      if !ass_ques.nil?
        temp_num=ass_ques.questionnaire_id
        questionnaire = assignment.questionnaires.find_by_id(temp_num)
      end
    end
    # E1450 end
    if questionnaire.nil?
      questionnaire = Object.const_get(type).new
    end

    questionnaire
  end
end

