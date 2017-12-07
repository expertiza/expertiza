require 'rspec'

def move_to_your_team
  login_as(User.where(role_id: 2).first.name)
  expect(page).to have_content @assignment.name
  click_link @assignment.name
  expect(page).to have_content "Your team"
  click_link "Your team"
end

describe 'Team invitation testing' do
  before(:each) do
    # create assignment
    # create assignment
    @assignment = create(:assignment)
    # add student to assignment
    @participant = create(:participant)
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
    create(:assignment_due_date, teammate_review_allowed_id: 1, deadline_type: DeadlineType.where(name: 'submission').first, due_at: Time.now.in_time_zone + 1.day)
  end
  it 'should verify that list of students displayed does not have a team or has a single member team only' do
    # specify assignment team size to be greater than 1
    # create team for assignment and keep number of team members less than allowed
    # add few participants with no team to the assignment
    # add few participants with single member team to the assignment
    create(:team_user, user: User.where(role_id: 2).first)
    create(:participant)
    create(:participant)
    # verify number of rows are equal to valid participants size
    move_to_your_team
    expect(page).to have_selector('table#table-send-request')
    # expected count is number of rows + 1 (for header)
    expect(page).to have_selector('table#table-send-request tr', :count => 3)
    # expected cound for td is number of rows * entry each row
    # table header is not included as it is tr th
    expect(page).to have_selector('table#table-send-request tr td', :count => 6)
  end
  it 'should not display any invitation link if user does not have a team' do
    # make sure student doesn't have a team
    # verify no invitation links
    move_to_your_team
    expect(page).to have_no_selector('table#table-send-request')
  end
  it 'should not display any invitation link if user\'s team is full' do
    # specify any assignment team size
    # create team for assignment and keep number of team members equal to allowed
    create(:participant)
    create(:participant)
    create(:team_user, user: User.where(role_id: 2).first)
    create(:team_user, user: User.where(role_id: 2).second)
    create(:team_user, user: User.where(role_id: 2).third)
    # verify no invitation links
    move_to_your_team
    expect(page).to have_no_selector('table#table-send-request')
  end
  it 'should not display any invitation link if assignment deadline is over' do
    # change deadline of assignment to be in past
    assignment_due_date = AssignmentDueDate.find(1)
    assignment_due_date.due_at = Time.now.in_time_zone - 1.day
    # verify no invitation links
    move_to_your_team
    expect(page).to have_no_selector('table#table-send-request')
  end
end