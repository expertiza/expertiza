describe 'timestamps for student submissions' do
  before(:each) do
    create(:assignment, name: "E1797-Test", directory_path: 'test_assignment')
    create_list(:participant, 3)
    create(:assignment_node)
    create(:deadline_type, name: "submission")
    create(:deadline_type, name: "review")
    create(:deadline_type, name: "metareview")
    create(:deadline_type, name: "drop_topic")
    create(:deadline_type, name: "team_formation")
    create(:deadline_right)
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'review').first, due_at: '2200-12-22T22:33:23.000-05:00')
    login_as("student2065")
    visit '/student_task/list'
  end

  it 'displays review due dates along with its timestamps' do
    # checks whether the UI has above given deadline
    click_link "E1797-Test"
    page.html.should include('2200-12-22T22:33:23.000-05:00')
  end

end
