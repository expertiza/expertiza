describe "peer review testing" do
  let(:review_response) { build(:response, id: 1, map_id: 1) }
  let(:review_response_round1) { build(:response, id: 1, map_id: 1, round: 1, is_submitted: 0) }
  let(:review_response_map) { build(:review_response_map, id: 1, reviewer: participant) }
  let(:questionnaire) { build(:questionnaire, id: 1, questions: [question]) }


  let(:answer) { double('Answer') }
  before(:each) do
    # create assignment and topic
    create(:assignment, name: "TestAssignment", directory_path: "TestAssignment")
    create(:question) { Criterion.new(id: 1, weight: 2, break_before: true) }
    create(:assignment_questionnaire) { build(:assignment_questionnaire) }
    create_list(:participant, 3)
    create(:topic, topic_name: "TestTopic")
    create(:deadline_type, name: "submission")
    create(:deadline_type, name: "review")
    create(:deadline_type, name: "metareview")
    create(:deadline_type, name: "drop_topic")
    create(:deadline_type, name: "signup")
    create(:deadline_type, name: "team_formation")
    create(:deadline_right)
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: "submission").first, due_at: DateTime.now.in_time_zone + 1.day)
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: "review").first, due_at: DateTime.now.in_time_zone + 1.day)

  end

  def signup_topic
    user = User.find_by(name: "student2064")
    stub_current_user(user, user.role.name, user.role)
    visit '/student_task/list'
    visit '/sign_up_sheet/sign_up?id=1&topic_id=1' # signup topic
    visit '/student_task/list'
    click_link "TestAssignment"
    click_link "Your work"
  end

  def submit_to_topic
    signup_topic
    fill_in 'submission', with: "https://www.ncsu.edu"
    click_on 'Upload link'
    expect(page).to have_content "https://www.ncsu.edu"
  end

  it "is able to submit a single valid link" do
    submit_to_topic
    # open the link and check content
    click_on "https://www.ncsu.edu"
    expect(page).to have_http_status(200)
  end

  it "is not able to select review with no submissions" do
    user = User.find_by(name: "student2065")
    stub_current_user(user, user.role.name, user.role)
    visit '/student_task/list'
    click_link "TestAssignment"
    click_link "Others' work"
    find(:css, "#i_dont_care").set(true)
    click_button "Request a new submission to review"
    expect(page).to have_content "No topics are available to review at this time. Please try later."
  end

  it "is not able to be assigned to review a topic only they have submitted on" do
    submit_to_topic
    visit '/student_task/list'
    click_link "TestAssignment"
    click_link "Others' work"
    find(:css, "#i_dont_care").set(true)
    click_button "Request a new submission to review"
    expect(page).to have_content "No topics are available to review at this time. Please try later."
  end

  it "is not able to select topic for review only they have submitted to" do
    submit_to_topic
    visit '/student_task/list'
    click_link "TestAssignment"
    click_link "Others' work"
    expect(page).to have_content 'Reviews for "TestAssignment"'
    expect(page).not_to have_button("topic_id_#{SignUpTopic.find_by(topic_name: 'TestTopic').id}")
  end

  it "is able to select topic for review with valid submissions" do
    submit_to_topic
    user = User.find_by(name: "student2065")
    stub_current_user(user, user.role.name, user.role)
    visit '/student_task/list'
    visit '/sign_up_sheet/sign_up?id=1&topic_id=1'
    visit '/student_task/list'
    click_link "TestAssignment"
    click_link "Others' work"
    choose "topic_id_#{SignUpTopic.find_by(topic_name: 'TestTopic').id}"
    click_button "Request a new submission to review"
    expect(page).to have_content "No previous versions available"
  end

  it "is able to be assigned random topic for review" do
    submit_to_topic
    user = User.find_by(name: "student2065")
    stub_current_user(user, user.role.name, user.role)
    visit '/student_task/list'
    visit '/sign_up_sheet/sign_up?id=1&topic_id=1'
    visit '/student_task/list'
    click_link "TestAssignment"
    click_link "Others' work"
    find(:css, "#i_dont_care").set(true)
    click_button "Request a new submission to review"
    expect(page).to have_content "No previous versions available"
  end

  it "shows student suggestion score for saving review", :js=>true do
    submit_to_topic
    user = User.find_by(name: "student2066")
    stub_current_user(user,user.role.name,user.role)
    visit '/student_task/list'
    visit '/sign_up_sheet/sign_up?id=1&topic_id=1'
    visit '/student_task/list'
    click_link "TestAssignment"
    click_link "Others' work"
    find(:css, "#i_dont_care").set(true)
    click_button "Request a new submission to review"
    click_link "Begin"
    click_button "Save Review"
    wait = Selenium::WebDriver::Wait.new(:timeout => 30)
    wait.until {
      begin
        text = page.driver.browser.switch_to.alert.text
        ans = text.split('.')
        what=ans[1].split()
        expect(what[-1].to_i).to be_a_kind_of(Integer)
        content = "Your review suggestion score is " + what[-1]
        expect(text).to have_content content
        true
      rescue Selenium::WebDriver::Error::NoAlertPresentError
        false
      end
    }
    page.driver.browser.switch_to.alert.accept
  end

  it "shows student suggestion score for submitting review", :js=>true do
    submit_to_topic
    user = User.find_by(name: "student2066")
    stub_current_user(user,user.role.name,user.role)
    visit '/student_task/list'
    visit '/sign_up_sheet/sign_up?id=1&topic_id=1'
    visit '/student_task/list'
    click_link "TestAssignment"
    click_link "Others' work"
    find(:css, "#i_dont_care").set(true)
    click_button "Request a new submission to review"
    click_link "Begin"
    click_button "Submit Review"
    wait = Selenium::WebDriver::Wait.new(:timeout => 30)
    wait.until {
      begin
        text = page.driver.browser.switch_to.alert.text
        expect(text).to have_content "Once a review has been submitted, you cannot edit it again"
        ans = text.split('.')
        what=ans[1].split()
        expect(what[-1].to_i).to be_a_kind_of(Integer)
        content = "Your review suggestion score is " + what[-1]
        expect(text).to have_content content
        true
      rescue Selenium::WebDriver::Error::NoAlertPresentError
        false
      end
    }
    page.driver.browser.switch_to.alert.accept
  end

  it "shows valid student suggestion score when saving review", :js=>true do
    submit_to_topic
    user = User.find_by(name: "student2066")
    stub_current_user(user,user.role.name,user.role)
    visit '/student_task/list'
    visit '/sign_up_sheet/sign_up?id=1&topic_id=1'
    visit '/student_task/list'
    click_link "TestAssignment"
    click_link "Others' work"
    find(:css, "#i_dont_care").set(true)
    click_button "Request a new submission to review"
    click_link "Begin"
    click_button "Save Review"
    wait = Selenium::WebDriver::Wait.new(:timeout => 30)
    wait.until {
      begin
        text = page.driver.browser.switch_to.alert.text
        ans = text.split('.')
        what=ans[1].split()
        expect(what[-1].to_i).to be_between(0,10)
        true
      rescue Selenium::WebDriver::Error::NoAlertPresentError
        false
      end
    }
    page.driver.browser.switch_to.alert.accept
  end

  it "shows valid student suggestion score when submitting review", :js=>true do
    submit_to_topic
    user = User.find_by(name: "student2066")
    stub_current_user(user,user.role.name,user.role)
    visit '/student_task/list'
    visit '/sign_up_sheet/sign_up?id=1&topic_id=1'
    visit '/student_task/list'
    click_link "TestAssignment"
    click_link "Others' work"
    find(:css, "#i_dont_care").set(true)
    click_button "Request a new submission to review"
    click_link "Begin"
    click_button "Submit Review"
    wait = Selenium::WebDriver::Wait.new(:timeout => 30)
    wait.until {
      begin
        text = page.driver.browser.switch_to.alert.text
        ans = text.split('.')
        what=ans[1].split()
        expect(what[-1].to_i).to be_between(0,10)
        true
      rescue Selenium::WebDriver::Error::NoAlertPresentError
        false
      end
    }
    page.driver.browser.switch_to.alert.accept
  end

end
