require 'rails_helper'
require 'selenium-webdriver'


describe 'Student can select their duty with duty share', js: true do
  before(:each) do
    # Create an instructor
    @instructor = create(:instructor)

    # Create a student
    @student = create(:student)

    # Create an assignment with quiz
    @assignment = create :assignment, duty_based: true, instructor: @instructor, duty_names: "writer, analyst, tester", allow_duty_share: true

    # Create an assignment due date
    create(:deadline_type, name: "submission")
    create(:deadline_type, name: "review")
    create(:deadline_type, name: "metareview")
    create(:deadline_type, name: "drop_topic")
    create(:deadline_type, name: "signup")
    create(:deadline_type, name: "team_formation")
    create(:deadline_right)
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')
    create :assignment_due_date, due_at: (DateTime.now + 1)

    @review_deadline_type = create(:deadline_type, name: "review")
    create :assignment_due_date, due_at: (DateTime.now + 1), deadline_type: @review_deadline_type

    # Create a team linked to the calibrated assignment
    @team = create :assignment_team, assignment: @assignment

    # Create an assignment participant linked to the assignment
    @participant = create :participant, assignment: @assignment, user: @student

    # Create a mapping between the assignment team and the
    # participant object's user (the submitter).
    create :team_user, team: @team, user: @student
    create :review_response_map, assignment: @assignment, reviewee: @team
  end


  it 'page should have select duty option' do
    login_as @student.name
    click_link @assignment.name
    click_link 'Your team'
    expect(page).to have_link('select duty')
  end


  it 'should be able to select duty' do
    login_as @student.name
    click_link @assignment.name
    click_link 'Your team'
    click_link 'select duty'
    select "analyst", from: 'duty'
    click_button 'Save'
    click_on 'Back'
    click_on 'Back'
    page.evaluate_script 'window.location.reload()'
    expect(page).to have_content('analyst')
    expect(page).to have_link('Update duty')
  end

  it 'should see update duty' do
    login_as @student.name
    click_link @assignment.name
    click_link 'Your team'
    click_link 'select duty'
    select "analyst", from: 'duty'
    click_button 'Save'
    click_on 'Back'
    click_on 'Back'
    page.evaluate_script 'window.location.reload()'
    expect(page).to have_content('analyst')
    expect(page).to have_link('Update duty')

  end

  it 'should be able to update duty' do
    login_as @student.name
    click_link @assignment.name
    click_link 'Your team'
    click_link 'select duty'
    select "analyst", from: 'duty'
    click_button 'Save'
    click_on 'Back'
    click_on 'Back'
    page.evaluate_script 'window.location.reload()'
    click_link "Update duty"
    select "tester", from: 'duty'
    click_button 'Save'
    click_on 'Back'
    click_on 'Back'
    page.evaluate_script 'window.location.reload()'
    expect(page).to have_content('tester')
  end

end
