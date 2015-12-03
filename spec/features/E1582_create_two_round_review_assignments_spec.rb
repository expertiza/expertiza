require 'spec_helper'

feature 'Create a two-round review assignment' do
  scenario 'without a topic' do
    #FIXME
    #Capybara.default_max_wait_time = 5
    login_with 'instructor6', 'password'
    expect(page).to have_content('Manage content')
    click_link( 'Assignments', match: :first)
    expect(page).to have_content('Manage content')
    #find(:xpath, "(//a[text()='Assignments'])[2]").click

    visit new_assignment_path
    #expect(page).to have_content('WCAE 2015')
    #expect(page).to have_no_content('Select an assignment from the list or set')
#AssignmentNode_1446_1
    #click_button 'assignment_newfalse.1'
    expect(page).to have_content('New Assignment')
    fill_in 'Assignment name:', with: 'E1583_test_1'
    fill_in 'Submission directory', with: 'E1583_test_1'
    select "CSC/ECE 517, Spring 2015", :from => "assignment_form_assignment_course_id"
    check 'assignment_form_assignment_staggered_deadline'

    click_button 'Create'
    expect(page).to have_content('You did not specify all necessary rubrics:')
    click_on 'Due dates'
    fill_in 'Number of review rounds:', with: '2'
    click_button 'Set'

    click_on 'Rubrics'
    
    expect(page).to have_content('Review rubric varies by round?')
    #require 'pry'
    #binding.pry
    within('#questionnaire_table_ReviewQuestionnaire', visible: false) do
      find("option[value='115']").click
    end
#questionnaire_table_ReviewQuestionnaire > td:nth-child(3) > select:nth-child(1) > option:nth-child(2)
    #select "Chapter Review", from: "#questionnaire_table_ReviewQuestionnaire > td:nth-child(3) > select:nth-child(1)", visible: false
    #page.all("wiki", match: :first, visible: false).last.click  
#find("#questionnaire_table_ReviewQuestionnaire > td:nth-child(3) > select:nth-child(1)", :visible=>false)
    #click_button 'Save'
    #expect(page).to have_content('Assignment was successfully saved')
  end

  scenario 'with a topic' do
    #FIXME
    login_with 'instructor6', 'passwordrowssap'
    expect(page).to have_content('Incorrect Name/Password')



    #within find('tr', text: 'My title') { click_link 'edit' }
    #select 'No', from: "suggestion_signup_preference"
  end

  def login_with(username, password)
    visit root_path
    fill_in 'login_name', with: username
    fill_in 'login_password', with: password
    click_button 'SIGN IN'
  end
end
