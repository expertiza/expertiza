require 'rails_helper'

describe "validations" do
  before(:each) do
    @assignment = build(:assignment)
  end

  it "assignment is valid" do
    expect(@assignment).to be_valid
  end

  it "assignment without name is not valid" do
    @assignment.name = nil
    @assignment.save
    expect(@assignment).not_to be_valid
  end

  it "checks whether Assignment Team is created or not" do
    expect(create(:assignment_team)).to be_valid
  end

  it "checks whether signed up topic is created or not" do
    expect(create(:topic)).to be_valid
  end
end

describe "#team_assignment" do
  it "checks an assignment has team" do
    assignment = build(:assignment)
    expect(assignment.team_assignment).to be true
  end
end

describe "#has_teams?" do
  it "checks an assignment has a team" do
    assignment = build(:assignment)
    assign_team = build(:assignment_team)
    assignment.teams << assign_team
    expect(assignment.has_teams?).to be true
  end
end

describe "#has_topics?" do
  it "checks an assignment has a topic" do
    assignment = build(:assignment)
    topic = build(:topic)
    assignment.sign_up_topics << topic
    expect(assignment.has_topics?).to be true
  end
end

describe "#is_google_doc" do
  it "checks whether assignment is a google doc" do
    skip('#is_google_doc no longer exists in assignment.rb file.')
    assignment = build(:assignment)
    res = assignment.is_google_doc
    expect(res).to be false
  end
end

describe "#is_microtask?" do
  it "checks whether assignment is a micro task" do
    assignment = build(:assignment, microtask: true)
    expect(assignment.is_microtask?).to be true
  end
end

describe "#dynamic_reviewer_assignment?" do
  it "checks the Review Strategy Assignment" do
    assignment = build(:assignment)
    expect(assignment.dynamic_reviewer_assignment?).to be true
  end
end

describe "#is_coding_assignment?" do
  it "checks assignment is coding assignment or not" do
    assignment = build(:assignment)
    expect(assignment.is_coding_assignment?).to be false
  end
end

describe "#candidate_assignment_teams_to_review" do
  it "returns nil if if there are no contributors" do
    assignment = build(:assignment)
    reviewer = build(:participant)
    cand_team = assignment.candidate_assignment_teams_to_review(reviewer)
    expect(cand_team).to be_empty
  end
end

describe "#candidate_topics_for_quiz" do
  it "returns nil if sign up topic is empty" do
    assignment = build(:assignment)
    cand_topic = assignment.candidate_topics_for_quiz
    expect(cand_topic).to be_nil
  end
end


describe "can not review own work", type: :feature do
    before(:each) do
        create(:assignment, name: "TestTeam", directory_path: 'test_team')
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
        create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'review').first, due_at: Time.now + (100 * 24 * 60 * 60))
        #create(:topic)
        create(:topic, topic_name: "work1")
    end
    
    #case1 team leader can invite a student to join team, and a student can accept the invitaion
    it "case1" do
        
        #test log in as a student
        
        user = User.find_by_name('student2064')
        msg = user.to_yaml
        File.open('log/diagnostic.txt', 'a') {|f| f.write msg }
        
        visit root_path
        fill_in 'login_name', with: 'student2064'
        fill_in 'login_password', with: 'password'
        click_button 'SIGN IN'
        
        
        
        #expect(page).to have_content "Welcome!"
        #expect(page).to have_content "Assignments"
        #click_link "Assignments"
        
        
        expect(page).to have_content "User: student2064"
        expect(page).to have_content "TestTeam"
        
        click_link "TestTeam"
        expect(page).to have_content "Signup sheet"
        expect(page).to have_content "Your team"
        
        #test if the topic can be seen and chosen by a student
        
        click_link "Signup sheet"
        expect(page).to have_content "work1"
        my_link = find(:xpath, "//a[contains(@href,'sign_up_sheet/sign_up?assignment_id=#{Assignment.last.id}&id=1')]")
        my_link.click
        
        
        #test after selecting a topic, a team formed
        click_link "Assignments"
        click_link "TestTeam"
        click_link "Your work"
        
        fill_in 'submission', with: 'www.google.com'
        click_button 'Upload link'
        
        click_link "Assignments"
        click_link "TestTeam"
        click_link "Others' work"
        
        click_button "Request a new submission to review"
        
        #If no link of view is on the page, then it means that no review is allowed for this user.
        expect(page).to have_no_link "view"
        
        #save_and_open_page
    end
end


