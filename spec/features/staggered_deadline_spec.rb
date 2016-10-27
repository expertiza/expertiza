require 'rails_helper'
#require 'selenium-webdriver'

describe "Staggered deadline test" do
  before(:each) do
    create(:assignment, name: "Assignment1665", directory_path: "Assignment1665", staggered_deadline: true)
    create_list(:participant, 3)
    create(:topic, topic_name: "Topic_1")
    create(:topic, topic_name: "Topic_2")
    create(:assignment_questionnaire, used_in_round: 1)
    create(:assignment_questionnaire, used_in_round: 2)
    create(:deadline_type, name: "submission")
    create(:deadline_type, name: "review")
    create(:deadline_type, name: "metareview")
    create(:deadline_type, name: "drop_topic")
    create(:deadline_type, name: "signup")
    create(:deadline_type, name: "team_formation")
    create(:deadline_right)
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')
    create(:assignment_due_date)
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'submission').first, due_at: Time.now + (100 * 24 * 60 * 60))
  end

  def topic_submit
#student1
    user = User.find_by_name('student2064')
    stub_current_user(user, user.role.name, user.role)

    visit '/student_task/list'
    expect(page).to have_content "User: student2064"
    expect(page).to have_content "Assignment1665"

    visit '/sign_up_sheet/sign_up?assignment_id=1&id=1' #signup topic1

    visit '/student_task/list'

    click_link "Assignment1665"
    expect(page).to have_content "Submit or Review work for Assignment1665"
    expect(page).to have_content "Signup sheet"

    click_link "Your work"
    expect(page).to have_content 'Submit work for Assignment1665'
    expect(page).to have_content 'Submit a hyperlink:'


    fill_in 'submission', with:'https://google.com'
    click_on 'Upload link'
    expect(page).to have_content "https://google.com"

#student 2
user = User.find_by_name('student2065')
    stub_current_user(user, user.role.name, user.role)

    visit '/student_task/list'
    expect(page).to have_content "User: student2065"
    expect(page).to have_content "Assignment1665"

    visit '/sign_up_sheet/sign_up?assignment_id=1&id=2' #signup topic1

    visit '/student_task/list'

    click_link "Assignment1665"
    expect(page).to have_content "Submit or Review work for Assignment1665"
    expect(page).to have_content "Signup sheet"

    click_link "Your work"
    expect(page).to have_content 'Submit work for Assignment1665'
    expect(page).to have_content 'Submit a hyperlink:'


    fill_in 'submission', with:'https://ncsu.edu'
    click_on 'Upload link'
    expect(page).to have_content "https://ncsu.edu"
  end

  
  it "test 1" do
    topic_submit
  end
end
