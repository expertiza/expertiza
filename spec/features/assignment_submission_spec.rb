require 'rails_helper'

describe "assignment submisstion test" do
  before(:each) do
    #create assignment and topic
    create(:assignment, name: "Assignment1684", directory_path: "Assignment1684")
    create_list(:participant, 3)
    create(:topic, topic_name: "Topic")
    create(:deadline_type, name: "submission")
    create(:deadline_type, name: "review")
    create(:deadline_type, name: "metareview")
    create(:deadline_type, name: "drop_topic")
    create(:deadline_type, name: "signup")
    create(:deadline_type, name: "team_formation")
    create(:deadline_right)
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: "submission").first, due_at: DateTime.now + 1)
  end

  def signup_topic
    user = User.find_by_name("student2064")
    stub_current_user(user, user.role.name, user.role)
    visit '/student_task/list'
    visit '/sign_up_sheet/sign_up?id=1&topic_id=1' #signup topic
    visit '/student_task/list'
    click_link "Assignment1684"
    click_link "Your work"
  end

  it "test1: submit single link" do
    signup_topic
    fill_in 'submission', with: "https://google.com"
    click_on 'Upload link'
    expect(page).to have_content "https://google.com"
  end

  it "test2: submit multiple link" do
    signup_topic
    fill_in 'submission', with: "https://google.com"
    click_on 'Upload link'
    expect(page).to have_content "https://google.com"
    fill_in 'submission', with: "https://baidu.com"
    click_on 'Upload link'
    expect(page).to have_content "https://baidu.com"
    fill_in 'submission', with: "https://bing.com"
    click_on 'Upload link'
    expect(page).to have_content "https://bing.com"
  end

  it "test3: submit unvalid link" do
    signup_topic
    fill_in 'submission', with: "wolfpack"
    click_on 'Upload link'
    expect(page).to have_content "The URL or URI is not valid"  
  end

  it "test4: submit duplicated link" do
    signup_topic
    fill_in 'submission', with: "https://google.com"
    click_on 'Upload link'
    fill_in 'submission', with: "https://google.com"
    click_on 'Upload link'
    expect(page).to have_content "You or your teammate(s) have already submitted the same hyperlink."  
  end

end



























