require 'rails_helper'

describe "Staggered deadline test" do
  before(:each) do
    #assignment and topic
    create(:assignment, name: "Assignment1665", directory_path: "Assignment1665", rounds_of_reviews: 2, staggered_deadline: true)
    create_list(:participant, 3)
    create(:topic, topic_name: "Topic_1")
    create(:topic, topic_name: "Topic_2")
    #rubric
    create(:questionnaire, name: "TestQuestionnaire1")
    create(:questionnaire, name: "TestQuestionnaire2")
    create(:question, txt: "Question1", questionnaire: ReviewQuestionnaire.where(name: 'TestQuestionnaire1').first, type: "Criterion")
    create(:question, txt: "Question2", questionnaire: ReviewQuestionnaire.where(name: 'TestQuestionnaire2').first, type: "Criterion")
    create(:assignment_questionnaire, questionnaire: ReviewQuestionnaire.where(name: 'TestQuestionnaire1').first, used_in_round: 1)
    create(:assignment_questionnaire, questionnaire: ReviewQuestionnaire.where(name: 'TestQuestionnaire2').first, used_in_round: 2)
    #deadline type
    create(:deadline_type, name: "submission")
    create(:deadline_type, name: "review")
    create(:deadline_type, name: "metareview")
    create(:deadline_type, name: "drop_topic")
    create(:deadline_type, name: "signup")
    create(:deadline_type, name: "team_formation")
    create(:deadline_right)
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')
    #assignment deadline
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'submission').first, due_at: DateTime.now + 10, round: 1)
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'review').first, due_at: DateTime.now + 20, round: 1)
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'submission').first, due_at: DateTime.now + 30, round: 2)
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'review').first, due_at: DateTime.now + 40, round: 2)
    #topic deadline
    create(:topic_due_date, due_at: DateTime.now + 10, deadline_type: DeadlineType.where(name: 'submission').first, topic: SignUpTopic.where(id: 1).first, round: 1)
    create(:topic_due_date, due_at: DateTime.now + 20, deadline_type: DeadlineType.where(name: 'review').first, topic: SignUpTopic.where(id: 1).first, round: 1)
    create(:topic_due_date, due_at: DateTime.now + 30, deadline_type: DeadlineType.where(name: 'submission').first, topic: SignUpTopic.where(id: 1).first, round: 2)
    create(:topic_due_date, due_at: DateTime.now + 40, deadline_type: DeadlineType.where(name: 'review').first, topic: SignUpTopic.where(id: 1).first, round: 2)
    create(:topic_due_date, due_at: DateTime.now + 10, deadline_type: DeadlineType.where(name: 'submission').first, topic: SignUpTopic.where(id: 2).first, round: 1)
    create(:topic_due_date, due_at: DateTime.now + 20, deadline_type: DeadlineType.where(name: 'review').first, topic: SignUpTopic.where(id: 2).first, round: 1)
    create(:topic_due_date, due_at: DateTime.now + 30, deadline_type: DeadlineType.where(name: 'submission').first, topic: SignUpTopic.where(id: 2).first, round: 2)
    create(:topic_due_date, due_at: DateTime.now + 40, deadline_type: DeadlineType.where(name: 'review').first, topic: SignUpTopic.where(id: 2).first, round: 2)
  end 
 
  #impersonate student to submit work
  def submit_topic  
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

    visit '/sign_up_sheet/sign_up?assignment_id=1&id=2' #signup topic2

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

  def change_due(topic, type, round, time)
     topic_due = TopicDueDate.where(parent_id: topic, deadline_type_id: type, round: round, type: "TopicDueDate").first
     topic_due.due_at = time
     topic_due.save
  end

  it "test1: in round 1, student2064 should be in review stage, student2065 in submission stage" do
     #impersonate each participant submit their topics
     submit_topic

     #change deadline to make student2064 in review stage in round 1
     change_due(1, 1, 1, DateTime.now - 10)

     #impersonate each participant and check their topic's current stage
     user = User.find_by_name('student2064')
     stub_current_user(user, user.role.name, user.role)
     visit '/student_task/list'
     expect(page).to have_content "review"

     #student in review stage could review others' work
     click_link 'Assignment1665'
     expect(page).to have_content "Others' work"
     click_link "Others' work"
     expect(page).to have_content 'Reviews for "Assignment1665"'
     choose "topic_id_2"
     click_button 'Request a new submission to review'
     expect(page).to have_content "Review 1."
     click_link "Begin"
     expect(page).to have_content "You are reviewing Topic_2"
     
     #check it is the right rubric for this round
     expect(page).to have_content "Question1"

     #Check fill in rubrics and save, submit the review
     select 5, from: "responses_0_score"
     fill_in "responses_0_comments", with: "test fill"
     click_button "Save Review"
     expect(page).to have_content "View"
  end


  it "test2: in round 2, both students should be in review stage" do
     #impersonate each participant submit their topics
     submit_topic
     #change deadline to make both in review stage in round 2
     change_due(1, 1, 1, DateTime.now - 30)
     change_due(1, 2, 1, DateTime.now - 20)
     change_due(1, 1, 2, DateTime.now - 10)
     change_due(2, 1, 1, DateTime.now - 30)
     change_due(2, 2, 1, DateTime.now - 20)
     change_due(2, 1, 2, DateTime.now - 10)

     #impersonate each participant and check their topic's current stage

     ###first student:
     user = User.find_by_name('student2064')
     stub_current_user(user, user.role.name, user.role)
     visit '/student_task/list'
     expect(page).to have_content "review"

     #student in review stage could review others' work
     click_link 'Assignment1665'
     expect(page).to have_content "Others' work"
     click_link "Others' work"
     expect(page).to have_content 'Reviews for "Assignment1665"'
     choose "topic_id_2"
     click_button 'Request a new submission to review'
     expect(page).to have_content "Review 1."
     click_link "Begin"
     expect(page).to have_content "You are reviewing Topic_2"
     
     #check it is the right rubric for this round
     expect(page).to have_content "Question2"

     #Check fill in rubrics and save, submit the review
     select 5, from: "responses_0_score"
     fill_in "responses_0_comments", with: "test fill"
     click_button "Save Review"
     expect(page).to have_content "View"

     ###second student
     user = User.find_by_name('student2065')
     stub_current_user(user, user.role.name, user.role)
     visit '/student_task/list'
     expect(page).to have_content "review"

     #student in review stage could review others' work
     click_link 'Assignment1665'
     expect(page).to have_content "Others' work"
     click_link "Others' work"
     expect(page).to have_content 'Reviews for "Assignment1665"'
     choose "topic_id_1"
     click_button 'Request a new submission to review'
     expect(page).to have_content "Review 1."
     click_link "Begin"
     expect(page).to have_content "You are reviewing Topic_1"
     
     #check it is the right rubric for this round
     expect(page).to have_content "Question2"

     #Check fill in rubrics and save, submit the review
     select 5, from: "responses_0_score"
     fill_in "responses_0_comments", with: "test fill"
     click_button "Save Review"
     expect(page).to have_content "View"
  end

  it "test3: in round 2, both students after review deadline" do
     #impersonate each participant submit their topics
     submit_topic

     #change deadline to make both after review deadline in round 2
     change_due(1, 1, 1, DateTime.now - 40)
     change_due(1, 2, 1, DateTime.now - 30)
     change_due(1, 1, 2, DateTime.now - 20)
     change_due(1, 2, 2, DateTime.now - 10)
     change_due(2, 1, 1, DateTime.now - 40)
     change_due(2, 2, 1, DateTime.now - 30)
     change_due(2, 1, 2, DateTime.now - 20)
     change_due(2, 2, 2, DateTime.now - 10)

     #impersonate each participant and check their topic's current stage
     user = User.find_by_name('student2064')
     stub_current_user(user, user.role.name, user.role)
     visit '/student_task/list'
     expect(page).to have_content "Finished"

     #student in finish stage can not review others' work
     click_link 'Assignment1665'
     expect(page).to have_content "Others' work"
     click_link "Others' work"
     expect(page).to have_content 'Reviews for "Assignment1665"'
     #it should not able to choose topic for review
     expect{choose "topic_id_2"}.to raise_error('Unable to find radio button "topic_id_2"')
  end

end

