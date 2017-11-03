include InstructorInterfaceHelperSpec
describe 'bidding process test', js: true do
  before(:each) do
    assignment_setup
    login_as("instructor6")
    visit 'assignments/1/edit'
    visit '/sign_up_sheet/new?id=1'
    fill_in "topic_topic_identifier", with: "1"
    fill_in "topic_topic_name", with: "topic1"
    fill_in "topic_max_choosers", with:"2"
    click_button "Create"


    visit '/sign_up_sheet/new?id=1'
    fill_in "topic_topic_identifier", with: "2"
    fill_in "topic_topic_name", with: "topic2"
    fill_in "topic_max_choosers", with:"2"
    click_button "Create"


    visit '/sign_up_sheet/new?id=1'
    fill_in "topic_topic_identifier", with: "3"
    fill_in "topic_topic_name", with: "topic3"
    fill_in "topic_max_choosers", with:"2"
    click_button "Create"
    click_link "Topics"
    check "assignment_form[assignment][is_intelligent]"
    click_button "Save"
    click_link "Topics"
  end

  it "should run bidding algorithm successfully" do
    user = User.find_by_name("student2064")
    stub_current_user(user, user.role.name, user.role)
    visit '/student_task/list'
    click_link "final2"

    visit '/sign_up_sheet/sign_up?id=1&topic_id=1'
#      drag and drop
    source = page.find('#topics')
    target = page.find('#selections')
    source.drag_to(target)


    user = User.find_by_name("instructor6")
    stub_current_user(user, user.role.name, user.role)
    visit '/tree_display/list'
    all('a', :text => 'Assignments')[1].click
    visit "/lottery/run_intelligent_assignment/1"
    expect(page).to have_content('The intelligent assignment was successfully completed for final2')
  end

  it "should fail when no student bids" do
    visit '/tree_display/list'
    all('a', :text => 'Assignments')[1].click
    visit "/lottery/run_intelligent_assignment/1"
    expect(page).to have_content('500 Internal Server Error')
  end

  it "should do assignment after running bidding algorithm" do
    user = User.find_by_name("student2064")
    stub_current_user(user, user.role.name, user.role)
    visit '/student_task/list'
    click_link "final2"

    visit '/sign_up_sheet/list?id=1'
    source = page.find('#topics')
    target = page.find('#selections')
    source.drag_to(target)


    user = User.find_by_name("instructor6")
    stub_current_user(user, user.role.name, user.role)
    visit '/tree_display/list'
    all('a', :text => 'Assignments')[1].click
    visit "/lottery/run_intelligent_assignment/1"
    expect(page).to have_content('The intelligent assignment was successfully completed for final2')

    user = User.find_by_name("student2064")
    stub_current_user(user, user.role.name, user.role)
    visit '/student_task/list'
    click_link "final2"

    visit '/sign_up_sheet/sign_up?id=1&topic_id=1'
    expect(page).to have_content('Your topic(s):')
  end

  it "should do assignment based on priority after running bidding algorithm" do
    user = User.find_by_name("student2064")
    stub_current_user(user, user.role.name, user.role)
    visit '/student_task/list'
    click_link "final2"

    visit '/sign_up_sheet/list?id=1'
    source = page.find('#topics')
    target = page.find('#selections')
    source.drag_to(target)

    visit '/sign_up_sheet/list?id=1'
    source = page.find('#topics')
    target = page.find('#selections')
    source.drag_to(target)

    user = User.find_by_name("instructor6")
    stub_current_user(user, user.role.name, user.role)
    visit '/tree_display/list'
    all('a', :text => 'Assignments')[1].click
    visit "/lottery/run_intelligent_assignment/1"
    expect(page).to have_content('The intelligent assignment was successfully completed for final2')

    user = User.find_by_name("student2064")
    stub_current_user(user, user.role.name, user.role)
    visit '/student_task/list'
    click_link "final2"

    visit '/sign_up_sheet/sign_up?id=1&topic_id=1'
    expect(page).to have_content('Your topic(s):')
  end

end
