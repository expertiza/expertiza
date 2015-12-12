require 'spec_helper'
require 'rails_helper'
require 'selenium-webdriver'

describe "E1582. Create integration tests for the instructor interface using capybara and rspec" do

  feature "Test1: Instructor login" do
    scenario "with valid username and password" do
      login_with 'admin', 'admin'
      expect(page).to have_content("Manage content")
    end

    scenario "with invalid username and password" do
      login_with 'admin', 'drowssap'
      expect(page).to have_content('Incorrect Name/Password')
    end
  end

  feature "Test2: Create a course" do
    scenario "should be able to create a public course or a private course" do
      login_with 'admin', 'admin'

      visit '/course/new?private=0'
      fill_in "Course Name", with: 'public course for test'
      click_button "Create"

      expect(Course.where(name: "public course for test")).to exist

      visit '/course/new?private=1'
      fill_in "Course Name", with: 'private course for test'
      click_button "Create"

      expect(Course.where(name: "private course for test")).to exist
    end
  end

  feature "Test3: View assignment scores" do
    scenario 'should be able to view scores' do
      login_with 'admin', 'admin'
      click_link( 'Assignments', match: :first)
      expect(page).to have_content('Assignments')
      #go to assignment chapter 11-12 madeup exercise scores
      visit '/grades/view?id=722'
      expect(page).to have_content('Class Average')
    end
  end

  feature "Test4: View review scores" do
    scenario "should be able to view review scores" do
      login_with 'admin', 'admin'
      expect(page).to have_content('Assignments')

      # view assignments
      visit '/tree_display/list'
      expect(page).to have_content('Assignments')

      # view review reports
      visit '/review_mapping/response_report?id=723'
      expect(page).to have_content('Review report')

      # view review scores
      visit '/popup/view_review_scores_popup?assignment_id=723&reviewer_id=29065'
      expect(page).to have_content('Review scores')

    end
  end

  feature "Test5: View author-feedback scores" do
    scenario "should be able to view author-feedback scores" do
      login_with 'admin', 'admin'
      expect(page).to have_content('Assignments')

      # view assignments
      visit '/tree_display/list'
      expect(page).to have_content('Assignments')

      # view assignment scores
      visit '/grades/view?id=722'
      expect(page).to have_content('Hide stats')

      # view author-feedback scores
      visit '/grades/view?id=722#user_student5689'
      expect(page).to have_content('Hide stats')

    end
  end

  feature 'Test6: Create a two-round review assignment' do
    scenario 'without a topic', :js => true do
      login_with 'admin', 'admin'
      expect(page).to have_content('Manage content')
      click_link( 'Assignments', match: :first)
      expect(page).to have_content('Manage content')
      #find(:xpath, "(//a[text()='Assignments'])[2]").click

      visit new_assignment_path
      expect(page).to have_content('New Assignment')
      create_assignment('E1582_test_1')
      expect(page).to have_content('You did not specify all necessary rubrics:')
      set_due_dates
      expect(page).to have_content('Assignment was successfully saved')
      visit '/tree_display/list'
      click_link( 'Delete', match: :first)
    end

    scenario 'with a topic', :js => true do
      login_with 'admin', 'admin'
      expect(page).to have_content('Manage content')
      click_link( 'Assignments', match: :first)
      expect(page).to have_content('Manage content')
      #find(:xpath, "(//a[text()='Assignments'])[2]").click

      visit new_assignment_path
      expect(page).to have_content('New Assignment')
      create_assignment('E1582_test_2')
      expect(page).to have_content('You did not specify all necessary rubrics:')
    
      click_on 'Topics'
      expect(page).to have_content('Signup topics have not yet been created.')

      click_on 'New topic'

      expect(page).to have_content('You are adding a topic to this assignment.')
      click_button('OK')
      expect(page).to have_content('Number of slots')
      fill_in 'topic_topic_identifier', with: '999'
      fill_in 'topic_topic_name', with: 'E1583_test_2_topic'
      fill_in 'topic_category', with: 'E1583'
      fill_in 'topic_max_choosers', with: '3'
      click_button 'Create'
      set_due_dates
      #expect(page).to have_content('Assignment was successfully saved')
      expect(page).to have_content('Assignment was successfully saved')
      visit '/tree_display/list'
      click_link( 'Delete', match: :first)
    end
  end

  def set_due_dates
    click_on 'Due dates'
    fill_in 'Number of review rounds:', with: '2'
    click_button 'Set'
    click_button 'Save'
    # Potential bug of expertiza, changes of the 'number of review rounds'
    # will only take effect after click both the Set and Save button
    click_on 'Due dates'
    #set the due dates time
    fill_in 'datetimepicker_submission_round_1', with: '2015/12/03 00:00'
    fill_in 'datetimepicker_review_round_1', with: '2015/12/06 00:00'
    fill_in 'datetimepicker_submission_round_2', with: '2015/12/11 00:00'
    fill_in 'datetimepicker_review_round_2', with: '2015/12/14 00:00'
    click_button 'Save'
  end

  def create_assignment(assignment_name)
    fill_in 'Assignment name:', with: assignment_name
    fill_in 'Submission directory', with: assignment_name
    select "CSC/ECE 517, Spring 2015", :from => "assignment_form_assignment_course_id"
    click_button 'Create'
  end

  def login_with(username, password)
    visit root_path
    fill_in 'login_name', with: username
    fill_in 'login_password', with: password
    click_button 'SIGN IN'
  end
end
