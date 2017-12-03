include InstructorInterfaceHelperSpec
describe 'timestamps for students submissions' do
  ###
  # Please follow the TDD process as much as you can.
  # Use factories to create necessary DB records.
  # Please avoid duplicated code as much as you can by moving the code to before(:each) block or separated methods.
  # RSpec feature tests examples: spec/features/airbrake_expection_errors_feature_tests_spec.rb
  # For single user login, please use login_as method.
  # If your tests need to switch to different users frequently,
  # please use stub_current_user(user, user.role.name, user.role) each time to stub login behavior.
  ###
  before(:each) do
    create(:assignment, name: "TestAssignment", directory_path: 'test_assignment')
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
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'review').first, due_at: Time.now.in_time_zone + 1.day)
    create(:topic)
    create(:topic, topic_name: "TestReview")
    create(:team_user, user: User.where(role_id: 2).first)
    create(:team_user, user: User.where(role_id: 2).second)
    create(:assignment_team)
    create(:team_user, user: User.where(role_id: 2).third, team: AssignmentTeam.second)
    create(:signed_up_team)
    create(:signed_up_team, team_id: 2, topic: SignUpTopic.second)
    create(:assignment_questionnaire)
    create(:question)
    login_as("student2065")
    visit '/student_task/list'
  end

  def signupt_topic
    user = User.find_by(name: "student2064")
    stub_current_user(user, user.role.name, user.role)
    visit '/student_task/list'
    visit '/sign_up_sheet/sign_up?id=1&topic_id=1' # signup topic
    visit '/student_task/list'
    click_link "TestAssignment"
    click_link "Your work"
  end

  def submit_to_topic
    signupt_topic
    fill_in 'submission', with: "https://www.ncsu.edu"
    click_on 'Upload link'
    expect(page).to have_content "https://www.ncsu.edu"
  end

  def submit_hyperlink
    visit '/student_task/list'
    click_link "TestAssignment"
    expect(page).to have_content("Your work")
    click_link "Your work"
    fill_in "submission", with: "http://www.google.com"
    click_button "Upload link"
    all('a', :text => 'Assignments')[1].click
    click_link "TestAssignment"
    expect(page).to have_content("Deadline")
    expect(page).to have_content("Submit Hyperlink")
  end

  def submit_file
    visit '/student_task/list'
    click_link "TestAssignment"
    expect(page).to have_content("Your work")
    click_link "Your work"
    file_path = Rails.root + "spec/features/assignment_submission_txts/valid_assignment_file.txt"
    attach_file('uploaded_file', file_path)
    click_on 'Upload file'
    all('a', :text => 'Assignments')[1].click
    click_link "TestAssignment"
    expect(page).to have_content("Deadline")
    expect(page).to have_content("Submit File")
  end

  def submit_review
    visit '/student_task/list'
    click_link "TestAssignment"
    click_link "Others' work"
    find(:css, "#i_dont_care").set(true)
    click_button "Request a new submission to review"
    expect(page).to have_content "Begin"
    click_link "Begin"
    fill_in "responses[0][comment]", with: "HelloWorld"
    select 5, from: "responses[0][score]"
    click_button "Submit Review"
    expect(page).to have_content "Your response was successfully saved."
    visit '/student_task/list'
    click_link "TestAssignment"
    expect(page).to have_content "Round 1 Review"
  end

  context 'when current assignment is in submission stage' do
    context 'when current participant does not submit anything yet' do
      it 'displays due dates of current assignment in student_task#list page' do
        click_link "TestAssignment"
        expect(page).to have_content("Deadline")
      end
    end

    context 'after current participant has submitted a hyperlink' do
      it 'displays hyperlinks with its timestamps' do
        # it also displays due dates
        submit_hyperlink
      end
    end

    context 'after current participant has uploaded a file' do
      it 'displays file names with its timestamps' do
        # it also displays due dates
        submit_file
      end
    end
  end

  context 'when current assignment (with single review round) is in review stage' do
    context 'after current participant reviews other\'s work' do
      it 'displays a link named \'review\' with its timestamps (you could redirect to that review by clicking the link) ' do
        # it also displays due dates
        # it also displays submitted files or hyperlinks
        submit_to_topic
        submit_review
      end
    end

    context 'after current participant finishes an author feedback' do
      xit 'displays a link named \'feedback\' with its timestamps (you could redirect to that feedback by clicking the link)' do
        # it also displays due dates
        # it also displays submitted files or hyperlinks
        # it also displays review links
        submit_to_topic
        user = User.find_by_name("student2064")
        stub_current_user(user, user.role.name, user.role)
        visit '/student_task/list'
        click_link "TestAssignment"
        click_link "Others' work"
        click_button("")
        find(:css, "#i_dont_care").set(true)
        click_button "Request a new submission to review"
        expect(page).to have_content "Begin"
        click_link "Begin"
        fill_in "responses[0][comment]", with: "HelloWorld"
        select 5, from: "responses[0][score]"
        click_button "Submit Review"
        expect(page).to have_content "Your response was successfully saved."
        user = User.find_by_name("student2065")
        stub_current_user(user, user.role.name, user.role)
        visit '/student_task/list'
        visit '/student_task/list'
        click_link "TestAssignment"
        click_link "Alternate View"
        expect(page).to have_content "Your response was successfully saved."
      end
    end
  end

  context 'when current assignment (with multiple review round) is in review stage' do
    context 'after current participant reviews other\'s work in round 1' do
      it 'displays a link named \'review\' with its round number (1) and timestamps (you could redirect to that review by clicking the link)' do
        # it also displays due dates
        # it also displays submitted files or hyperlinks
        submit_to_topic
        submit_file
        submit_review
      end
    end

    context 'after current participant reviews other\'s work in round 2' do
      it 'displays a link named \'review\' with its round number (2) and timestamps (you could redirect to that review by clicking the link)'

    end

    context 'after current participant finishes an author feedback' do
      it 'displays a link named \'feedback\' with its timestamps (you could redirect to that feedback by clicking the link)'

    end
  end
end
