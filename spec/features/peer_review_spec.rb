describe "peer review testing" do
  before(:each) do
    create(:assignment, name: "TestAssignment", directory_path: 'test_assignment')
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
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'review').first, due_at: Time.now.in_time_zone + 1.day)
    create(:topic)
    create(:topic, topic_name: "TestReview")
    create(:team_user, user: User.where(role_id: 2).first)
    create(:team_user, user: User.where(role_id: 2).second)
    create(:assignment_team)
    create(:team_user, user: User.where(role_id: 2).third, team: AssignmentTeam.second)
    create(:signed_up_team)
    create(:signed_up_team, team_id: 2, topic: SignUpTopic.second)
    create(:assignment_questionnaire)
    create(:question)
  end
    # create(:review_response_map, reviewer_id: User.where(role_id: 2).third.id)
    # create(:review_response_map, reviewer_id: User.where(role_id: 2).second.id, reviewee: AssignmentTeam.second)
    # sleep(10000)

  def load_questionnaire
    login_as('student2064')
    expect(page).to have_content "User: student2064"
    expect(page).to have_content "TestAssignment"

    click_link "TestAssignment"
    expect(page).to have_content "Submit or Review work for TestAssignment"
    expect(page).to have_content "Others' work"

    click_link "Others' work"
    expect(page).to have_content 'Reviews for "TestAssignment"'

    choose "topic_id"
    click_button "Request a new submission to review"

    click_link "Begin"
  end

  it "fills in a single textbox and saves" do
    # Load questionnaire with generic setup
    load_questionnaire

    # Fill in a textbox and a dropdown
    fill_in "responses[0][comment]", with: "HelloWorld"
    select 5, from: "responses[0][score]"
    click_button "Submit Review"
    expect(page).to have_content "Your response was successfully saved."
  end

  it "fills in a single comment with multi word text and saves" do
    # Load questionnaire with generic setup
    load_questionnaire
    # Fill in a textbox with a multi word comment
    fill_in "responses[0][comment]", with: "Excellent Work"
    click_button "Submit Review"
    expect(page).to have_content "Your response was successfully saved."
  end

  it "fills in a single comment with single word and saves" do
    # Load questionnaire with generic setup
    load_questionnaire
    # Fill in a textbox with a single word comment
    fill_in "responses[0][comment]", with: "Excellent"
    click_button "Submit Review"
    expect(page).to have_content "Your response was successfully saved."
  end

  it "fills in only points and saves" do
    # Load questionnaire with generic setup
    load_questionnaire
    # Fill in a dropdown with some points
    select 5, from: "responses[0][score]"
    click_button "Submit Review"
    expect(page).to have_content "Your response was successfully saved."
  end

  it "saves an empty review without any points and comments" do
    # Load questionnaire with generic setup
    load_questionnaire
    click_button "Submit Review"
    expect(page).to have_content "Your response was successfully saved."
  end

  it "saves a review with only additional comments" do
    # Load questionnaire with generic setup
    load_questionnaire

    # Filling in Additional Comments only
    fill_in "review[comments]", with: "Excellent work done!"
    click_button "Submit Review"
    expect(page).to have_content "Your response was successfully saved."
  end
end

describe "review path testing" do
  before(:each) do
    create(:assignment, name: "ReviewTestAssignment", directory_path: 'review_test_assignment')
    @student1 = create(:student, name: "review_tester1", role_id: 1)
    @student2 = create(:student, name: "review_tester2", role_id: 1)
    @student3 = create(:student, name: "review_tester3", role_id: 1)
    create(:participant, user_id: @student1.id)
    create(:participant, user_id: @student2.id)
    @participant3 = create(:participant, user_id: @student3.id)
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
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'review').first, due_at: Time.now.in_time_zone + 1.day)
    create(:topic)
    create(:topic, topic_name: "TestReview")
    
    create(:team_user, user: @student1)
    create(:team_user, user: @student2)
    create(:assignment_team)
    create(:team_user, user: @student3, team: AssignmentTeam.second)
    create(:signed_up_team)
    create(:signed_up_team, team_id: 2, topic: SignUpTopic.second)
    create(:assignment_questionnaire)
    create(:question)
  end

  #participant id is 3 for student3
  normal_test_paths = [
    [["Student_task","Select an assignment"] ,["ReviewTestAssignment","Others' work"], ["Others' work",'Reviews for "ReviewTestAssignment"']],
    [["Contact Us","Welcome!"], ["Student_task","Select an assignment"], ["ReviewTestAssignment","Others' work"], ["Others' work",'Reviews for "ReviewTestAssignment"']],
    [["Home","Welcome!"], ["Student_task","Select an assignment"], ["ReviewTestAssignment","Others' work"], ["Others' work",'Reviews for "ReviewTestAssignment"']],
    [["Profile","User Profile Information"], ["Student_task","Select an assignment"], ["ReviewTestAssignment","Others' work"], ["Others' work",'Reviews for "ReviewTestAssignment"']],
    [["Student_task","Select an assignment"], ["/student_task/view?id=3","Others' work"], ["Others' work",'Reviews for "ReviewTestAssignment"']],
    [["Contact Us","Welcome!"], ["/student_task/view?id=3","Others' work"], ["Others' work",'Reviews for "ReviewTestAssignment"']],
    [["Home","Welcome!"], ["/student_task/view?id=3","Others' work"], ["Others' work",'Reviews for "ReviewTestAssignment"']],
    [["Profile","User Profile Information"], ["/student_task/view?id=3","Others' work"], ["Others' work",'Reviews for "ReviewTestAssignment"']],
    [["Student_task","Select an assignment"], ["/student_review/list?id=3",'Reviews for "ReviewTestAssignment"']],
    [["Contact Us","Welcome!"], ["/student_review/list?id=3",'Reviews for "ReviewTestAssignment"']],
    [["Home","Welcome!"], ["/student_review/list?id=3",'Reviews for "ReviewTestAssignment"']],
    [["Profile","User Profile Information"], ["/student_review/list?id=3",'Reviews for "ReviewTestAssignment"']],
    [["/student_task/list","Select an assignment"], ["ReviewTestAssignment","Others' work"], ["/student_task/list","Select an assignment"], ["ReviewTestAssignment","Others' work"],
        ["Others' work",'Reviews for "ReviewTestAssignment"']],
  ]

  normal_test_paths.each do |test_path| #loop to generate a test for every entry in test_paths. This will also ensure DB is reset between tests.
    description_list = []
    test_path.each do |path_step|
      description_list.append(path_step[0])
    end
    path_description = description_list.join(' -> ')
    path_description.concat(" -> Request a new submission to review -> Begin")
    it "user can take path #{path_description} to begin a review" do
      login_as(@student3.name)
      test_path.each do |path_step|
        where_to_go = path_step[0]
        expected_text = path_step[1]
        if where_to_go.include? '/' #if user navigates to page using direct url
          visit where_to_go
        else #if user navigates to page by normal means
          click_on(where_to_go)
        end
        expect(page).to have_content expected_text
      end
      choose "topic_id"
      click_on("Request a new submission to review")
      expect(page).to have_content "Begin"
      click_on("Begin")
      expect(page).to have_content "New Review for ReviewTestAssignment"
    end
  end
end