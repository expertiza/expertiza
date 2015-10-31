require 'rails_helper'
require 'spec_helper'

RSpec.feature 'assignment creation' do

  before(:each) do
    # Login as instructor
    visit root_path
    fill_in('login_name', :with => 'instructor6')
    fill_in('login_password', :with => 'password')
    click_on('SIGN IN')
    expect(page).to have_content('Manage')

    # Steps to create new ongoing public assignment

    # Step 1: Browse to new public assignment
    within('.content') do
      click_on('Assignments')
    end
    click_button 'New public assignment'

    # Step 2: Fill in details of new ongoing public assignment
    fill_in('assignment_form_assignment_name',:with => 'FeatureTest')
    select('CSC 517 Fall 2010', from: 'assignment_form_assignment_course_id')
    fill_in('assignment_form_assignment_directory_path',:with => 'csc517/oss')
    fill_in('assignment_form_assignment_spec_location',:with => 'feature test')
    check('assignment_form_assignment_availability_flag')
    click_on('Create')

    # Step 3: Specify grading rubrics for new ongoing public assignment
    click_on('Rubrics')
    within('#questionnaire_table_ReviewQuestionnaire') do
      select('Animation', from: 'assignment_form[assignment_questionnaire][][questionnaire_id]')
    end
    within('#questionnaire_table_AuthorFeedbackQuestionnaire') do
      select('Author feedback OTD1', from: 'assignment_form[assignment_questionnaire][][questionnaire_id]')
    end
    expect(page).to have_content("Rubrics")
    click_on('submit_btn')
    expect(page).to have_content("successfully",:wait=>5)

    # Step 4: Specify due dates for the new ongoing public assignment
    click_on('Due dates')
    fill_in('datetimepicker_submission_round_1',:with => '2015/11/10 23:00')
    fill_in('datetimepicker_review_round_1',:with => '2015/11/10 23:00')
    click_on('submit_btn')

    # Step 5: Add student13 as a participant to the new ongoing public assignment
    click_on('Manage...', :wait=>5)

    within(:xpath, "//table/tbody/tr[.//td[contains(.,'FeatureTest')]]") do
      find(:xpath, ".//a/img[@src='/assets/tree_view/add-participant-24.png']/..").click
    end
    expect(page).to have_content("Participants",:wait=>5)
    fill_in('user_name', :with => 'student13')
    click_on('add_a')

    # Steps to create new finished public assignment
    click_on('Manage...', :wait=>5)

    # Step 1: Browse to new public assignment
    click_button 'New public assignment'

    # Step 2: Fill in details of new finished public assignment
    fill_in('assignment_form_assignment_name',:with => 'LibraryRailsApp')
    select('CSC 517 Fall 2010', from: 'assignment_form_assignment_course_id')
    fill_in('assignment_form_assignment_directory_path',:with => 'csc517/rails')
    fill_in('assignment_form_assignment_spec_location',:with => 'rails application')
    check('assignment_form_assignment_availability_flag')
    click_on('Create')

    # Step 3: Specify grading rubrics for new finished public assignment
    click_on('Rubrics')
    within('#questionnaire_table_ReviewQuestionnaire') do
      select('Animation', from: 'assignment_form[assignment_questionnaire][][questionnaire_id]')
    end
    within('#questionnaire_table_AuthorFeedbackQuestionnaire') do
      select('Author feedback OTD1', from: 'assignment_form[assignment_questionnaire][][questionnaire_id]')
    end
    expect(page).to have_content("Rubrics")
    click_on('submit_btn')
    expect(page).to have_content("successfully",:wait=>5)

    # Step 4: Specify due dates for the new finished public assignment
    click_on('Due dates')
    fill_in('datetimepicker_submission_round_1',:with => '2015/9/9 23:00')
    fill_in('datetimepicker_review_round_1',:with => '2015/9/9 23:00')
    click_on('submit_btn')

    # Step 5: Add student13 as a participant to the new finished public assignment
    click_on('Manage...',:wait=>5)

    within(:xpath, "//table/tbody/tr[.//td[contains(.,'LibraryRailsApp')]]") do
      find(:xpath, ".//a/img[@src='/assets/tree_view/add-participant-24.png']/..").click
    end
    expect(page).to have_content("Participants",:wait=>5)
    fill_in('user_name', :with => 'student13')
    click_on('add_a')

  end


  scenario 'checked', :js => true do

    click_on('Manage...',:wait=>5)

    expect(page).to have_content 'FeatureTest'
    expect(page).to have_content 'LibraryRailsApp'

    # Logout
    find(:xpath, "//a[@href='/auth/logout']").click
  end

end
