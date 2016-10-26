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
  end

  def topic_submit
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

    #fill_in 'submission', with:'https://google.com'
    #click_on 'Upload link'
    #expect(page).to have_content "https://google.com"
  end
  
  it "test 1" do
    topic_submit
  end
end
