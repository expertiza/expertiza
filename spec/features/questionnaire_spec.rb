require 'rails_helper'

describe "Questionnaire tests for instructor interface" do

  before(:each) do
    create(:assignment)
    create_list(:participant, 3)
    create(:assignment_node)
    create(:deadline_type,name:"submission")
    create(:deadline_type,name:"review")
    create(:deadline_type,name:"resubmission")
    create(:deadline_type,name:"rereview")
    create(:deadline_type,name:"metareview")
    create(:deadline_type,name:"drop_topic")
    create(:deadline_type,name:"signup")
    create(:deadline_type,name:"team_formation")
    create(:deadline_right)
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')
    create(:due_date)
    create(:due_date, deadline_type: DeadlineType.where(name: 'review').first, due_at: Time.now + (100*24*60*60))
  end

describe "Instructor login" do
  it "with valid username and password" do
    login_as("instructor6")
    visit '/tree_display/list'
    expect(page).to have_content("Manage content")
  end

  it "with invalid username and password" do
    visit root_path
    fill_in 'login_name', with: 'instructor6'
    fill_in 'login_password', with: 'something'
    click_button 'SIGN IN'
    expect(page).to have_content('Incorrect Name/Password')
  end
end

describe "Create a review questionnaire", :type => :controller do

  it "is able to create a public review questionnaire" do

    login_as("instructor6")

    visit '/questionnaires/new?model=ReviewQuestionnaire&private=0'

    fill_in('questionnaire_name', :with => 'Review 1')

    fill_in('questionnaire_min_question_score', :with =>'7')

    fill_in('questionnaire_max_question_score', :with => '5')

    select('no', :from=> 'questionnaire_private')

    click_button "Create"

    expect(Questionnaire.where(name: "Review 1")).to exist

  end
end

end