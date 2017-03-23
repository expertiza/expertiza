require 'rails_helper'
require 'selenium-webdriver'

describe 'Student can view review scores in a heat map distribution', js: true do

  before(:each) do
    # Include setup here for pre-test stuff

    # Create a student
    @student = create(:student)

    # Create an instructor
    @instructor = create(:instructor)

    # Create an assignment
    @assignment = create :assignment, instructor: @instructor, course: nil, num_quiz_questions: 1

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
    create :assignment_due_date, due_at: (DateTime.now.in_time_zone + 1.day)

    @review_deadline_type = create(:deadline_type, name: "review")
    create :assignment_due_date, due_at: (DateTime.now.in_time_zone + 1.day), deadline_type: @review_deadline_type

    # This setup is from calibration_spec, 'Add Expert Review' better to use existing code to test with
    @questionnaire = create(:questionnaire)
    @assignment_questionnaire = create :assignment_questionnaire, assignment: @assignment

    # Create a team linked to the calibrated assignment
    @team = create :assignment_team, assignment: @assignment

    # Create an assignment participant linked to the assignment
    @participant = create :participant, assignment: @assignment, user: @student

    # Create a mapping between the assignment team and the
    # participant object's user (the submitter).
    create :team_user, team: @team, user: @student
    create :review_response_map, assignment: @assignment, reviewee: @team

  end

  it 'should be able to sort by total review score' do
    # This would require us to create several reviews 
  end

  it 'should be able to view a heat map of review scores' do
    # Log in as the student with an assignment and reviews
    login_as @student.name

    # Select the assignment and follow the link to the heat map
    click_link @assignment.name
    click_link 'Alternate View'

    expect(page).to have_content('Summary Report for assignment')
  end

  it 'should be able to follow the link to a specific review' do
    # Log in as the student with an assignment and reviews
    login_as @student.name

    # Select the assignment and follow the link to the heat map
    click_link @assignment.name
    click_link 'Review 1'

    expect(page).to have_content('Review for')
  end

  it 'should be able to toggle the question list' do
    # Log in as the student with an assignment and reviews
    login_as @student.name

    # Select the assignment and follow the link to the heat map
    click_link @assignment.name
    click_link 'toggle question list' # This is a link

    expect(page).to have_content('Question')
  end

end

describe 'Student does not have scores to show in a heat map distribution', js: true do

  before(:each) do
    @student = create(:student)
  end

  it 'should show an empty table with no reviews' do
    # Log in as the student with an assignment and reviews
    login_as @student.name
    expect(page).to_not have_content('Review 1')
  end
end
