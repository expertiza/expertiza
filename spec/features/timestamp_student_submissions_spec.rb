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
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'review').first, due_at: '2200-12-23 03:33:23')
    login_as("student2065")
    visit '/student_task/list'

  end

  it 'displays review due dates along with its timestamps' do
    #checks whether the UI has above given deadline
    page.html.should include('2200-12-23 03:33:23')
  end

  it 'displays submitted hyperlink along with timestamp' do
    #submit a generic link for this assignment
    click_link "E1797-Test"
    click_link "Your work"
    fill_in "submission", with: "http://www.google.com"
    click_button "Upload link"
    #expect the same link to be present in our graph
    page.all('a', :text => 'Assignments')[1].click
    click_link "E1797-Test"
    page.html.should include('https://www.google.com')
  end

  it 'displays submitted file along with timestamp' do
    #submit a generic file for this assignment
    click_link "E1797-Test"
    click_link "Your work"
    file_path = Rails.root + "spec/features/timestamp_students_submissions_spec.rb"
    attach_file('uploaded_file', file_path)
    click_on 'Upload file'
    #expect the same file to be present in our graph
    page.all('a', :text => 'Assignments')[1].click
    click_link "E1797-Test"
    page.html.should include('timestamp_students_submissions_spec.rb')
  end

end