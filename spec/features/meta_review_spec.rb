describe "meta-review user tests" do
  # In order to test the meta-review functionality as a user an assignment needs to have passed
  # the submission and review deadlines. It also requires two actors.
  #   1. The submitter is responsible for submitting the assignment and is the actor who
  #      is capable of completing a meta review.
  #   2. The reviewer is used to review the submitters submission.
  before(:each) do
    # Create an assignment. Defaults to 3 metareviews required and allowed.
    # See spec/factories/factories.rb  factory :assignment for more details on defaults.
    assignment = create(:assignment,
                        name: "TestAssignment",
                        directory_path: 'test_assignment')

    # Create a reivew
    reivew = create(:questionnaire, name: "Review")
    create(:question, txt: "ReviewQuestion1", questionnaire: reivew)
    create(:assignment_questionnaire, questionnaire: reivew, used_in_round: 1)

    # Populate deadline type
    create(:deadline_type, name: "submission")
    create(:deadline_type, name: "review")
    create(:deadline_right, name: 'No')
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')

    # Populate assignment deadlines
    submission_due_date = create(:assignment_due_date,
                                 deadline_type: DeadlineType.where(name: 'submission').first,
                                 due_at: Time.now + 1.day)
    review_due_date = create(:assignment_due_date,
                             deadline_type: DeadlineType.where(name: 'review').first,
                             due_at: Time.now + 2.day)

    # Add participants to assignment
    @submitter = create(:student, name: 'submit_and_meta_student')
    reviewer = create(:student, name: 'review_student')
    @reviewee = create(:participant, assignment: assignment, user: @submitter)
    @reviewer = create(:participant, assignment: assignment, user: reviewer)

    # The submitter submits an assigment to be reviewed.
    submit_assignment(@submitter)

    # Set the submission due date so it has already passed.
    submission_due_date.due_at = Time.now - 1.day
    submission_due_date.save

    # The reviewer reviews the submitted assignment
    review_assignment(reviewer)

    # Set the review due date so it has already passed.
    review_due_date.due_at = Time.now - 1.day
    review_due_date.save
  end

  # Impersonate student to submit the assignment
  def submit_assignment(user)
    stub_current_user(user, user.role.name, user.role)
    visit '/student_task/list'
    click_link "TestAssignment"
    click_link "Your work"
    fill_in 'submission', with: "https://ncsu.edu"
    click_on 'Upload link'
    expect(page).to have_content "https://ncsu.edu"
  end

  # Impersonate student to review the assignment
  def review_assignment(user)
    stub_current_user(user, user.role.name, user.role)
    visit '/student_task/list'
    expect(page).to have_content "review"
    click_link "TestAssignment"
    expect(page).to have_content "Others' work"
    click_link "Others' work"
    expect(page).to have_content 'Reviews for "TestAssignment"'
    click_button "Request a new submission to review"
    click_link "Begin"
    fill_in "responses[0][comment]", with: "This is garbage."
    click_button "Submit Review"
    expect(page).to have_content "Your response was successfully saved."
  end

  # Add meta-review parameters to the assignment that was defined first
  def add_meta_review
    create(:deadline_type, name: "metareview")
    create(:assignment_due_date,
           deadline_type: DeadlineType.where(name: 'metareview').first,
           due_at: Time.now + 3.day)
    # create a meta-review
    metareivew = create(:questionnaire, name: "Metareview", type: "MetareviewQuestionnaire")
    create(:question, txt: "MetaReviewQuestion", questionnaire: metareivew)
    create(:assignment_questionnaire, questionnaire: metareivew, used_in_round: 1)
  end

  context "has a meta-review" do
    before(:each) do
      add_meta_review
    end
    
    it "Student is able to leave a simple meta review." do
      stub_current_user(@submitter, @submitter.role.name, @submitter.role)
      visit '/student_task/list'
      expect(page).to have_content "metareview"
      click_link "TestAssignment"
      expect(page).to have_content "Others' work"
      click_link "Others' work"
      expect(page).to have_content 'Metareviews for "TestAssignment"'
      click_button "Request a new metareview to perform" 
      click_link "Begin"
      fill_in "responses[0][comment]", with: "Can you explain why this is garbage?"
      click_button "Save Metareview"
      expect(page).to have_content "Your response was successfully saved." 
    end
    
    it "If the metareview limit on the assignment is set to 3, then a student will see they need to submit 3 meta reviews" do
    
    end
    
    it "A student should not be able to request a metareview if they have reached the limit of their allowed reviews" do
    
    end
    
    it "A student should be able to request a metareview if they are above their required but below their allowed reviews" do

    end
  
    it "A student should not be able to request a metareview about their own work" do
  
    end
  
    it "A student should not be able to request a metareview about themselves" do
  
    end
  
    it "If a student has requested two metareviewes but have not submitted it, then they should not be able to request a new metareview." do
    
    end
  
    it "If the metareview limit on the assignment is set to 1 then a student should not be able to request a second meta review" do
  
    end
  end

  context "does not have a meta-review" do
    it "If the assignment does not have any legal meta reviews, then the 'Request a new metareview to perform' button is not visible" do
      
    end
  end
end