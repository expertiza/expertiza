describe "Meta-review tests" do
  # In order to test the meta-review functionality as a user an assignment needs to have passed
  # the submission and review deadlines. It also requires two actors.
  #   1. The submitter is responsible for submitting the assignment and is the actor who
  #      is capable of completing a meta review.
  #   2. The reviewer is used to review the submitters submission.
  before(:each) do
    # Create an assignment. Defaults to 3 metareviews required and allowed.
    # See spec/factories/factories.rb  factory :assignment for more details on defaults.
    @assignment = create(:assignment,
                         name: "TestAssignment",
                         directory_path: 'test_assignment')

    # Create a review
    review = create(:questionnaire, name: "Review")
    create(:question, txt: "ReviewQuestion1", questionnaire: review)
    create(:assignment_questionnaire, questionnaire: review, used_in_round: 1)

    # Populate deadline type
    create(:deadline_type, name: "submission")
    create(:deadline_type, name: "review")
    create(:deadline_right, name: 'No')
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')

    # Populate assignment deadlines
    @submission_due_date = create(:assignment_due_date,
                                 deadline_type: DeadlineType.where(name: 'submission').first,
                                 due_at: Time.now + 1.day)
    @review_due_date = create(:assignment_due_date,
                              deadline_type: DeadlineType.where(name: 'review').first,
                              due_at: Time.now + 2.day)

    # Add participants to assignment
    @submitter = create(:student, name: 'submit_and_meta_student')
    create(:participant, assignment: @assignment, user: @submitter)

    # The submitter submits an assigment to be reviewed.
    submit_assignment(@submitter)

    # Set the submission due date so it has already passed.
    set_due_date(@submission_due_date, Time.now - 1.day)
  end

  context "that have a meta-review deadline" do
    before(:each) do
      add_meta_review
    end
    
    context "with 0 reviewers." do
      before(:each) do
        # Set the review due date so it has already passed.
        set_due_date(@review_due_date, Time.now - 1.day)
      end
      
      it "User should NOT be able to see 'Request a new metareview to perfom' button when there are no reviews available" do
        stub_current_user(@submitter, @submitter.role.name, @submitter.role)
        visit '/student_task/list'
        expect(page).to have_content "metareview"
        click_link "TestAssignment"
        expect(page).to have_content "Others' work"
        click_link "Others' work"
        expect(page).to have_content 'Metareviews for "TestAssignment"'
        expect(page).to_not have_button "Request a new metareview to perform"
        expect(page).to have_content 'Meta-reviews cannot be performed at this time'
      end
    end
    
    context "with 1 reviewer." do
      before(:each) do
        # Create a review on the submitted assignment
        review_assignment("reviewer1", @assignment)
        
        # Set the review due date so it has already passed.
        set_due_date(@review_due_date, Time.now - 1.day)
      end
      
      it "User is able to SAVE a simple meta review." do
        stub_current_user(@submitter, @submitter.role.name, @submitter.role)
        visit '/student_task/list'
        expect(page).to have_content "metareview"
        click_link "TestAssignment"
        expect(page).to have_content "Others' work"
        click_link "Others' work"
        expect(page).to have_content 'Metareviews for "TestAssignment"'
        click_button "Request a new metareview to perform" 
        expect(page).to have_content "Begin"
        click_link "Begin"
        fill_in "responses[0][comment]", with: "Can you explain why this is garbage?"
        click_button "Submit Metareview"
        expect(page).to have_content "Your response was successfully saved."
        

        # We should see 'Edit' Because we are in the current round of the review.
        expect(page).to have_content "Edit" #TODO: This should be EDIT 
        expect(page).to have_content "View" 
      end

      it "User is able to SUBMIT a simple meta review." do
        submit_metareview(@submitter)
        
        # We should see 'Edit' Because we are in the current round of the review.
        expect(page).to_not have_content "Edit"
        expect(page).to_not have_content "Update"
        expect(page).to have_content "View" 
      end

      # it "User is able to SUBMIT a simple meta review." do
      #   stub_current_user(@submitter, @submitter.role.name, @submitter.role)
      #   visit '/student_task/list'
      #   expect(page).to have_content "metareview"
      #   click_link "TestAssignment"
      #   expect(page).to have_content "Others' work"
      #   click_link "Others' work"
      #   expect(page).to have_content 'Metareviews for "TestAssignment"'
      #   click_button "Request a new metareview to perform" 
      #   expect(page).to have_content "Begin"
      #   click_link "Begin"
      #   fill_in "responses[0][comment]", with: "Can you explain why this is garbage?"
      #   click_button "Save Metareview"
      #   expect(page).to have_content "Your response was successfully saved."
        
      #   # We should see 'Edit' Because we are in the current round of the review.
      #   expect(page).to have_content "Edit"
      #   expect(page).to have_content "View"

      #   # Set the meta review due date so it has already passed.
      #   @metareview_due_date.due_at = Time.now - 1.day
      #   @metareview_due_date.save

      #   visit '/student_task/list'
      #   click_link "TestAssignment"
      #   click_link "Others' work"
      #   expect(page).to have_content 'Metareviews for "TestAssignment"'
      #   expect(page).not_to have_content "Update"
      #   expect(page).not_to have_content "Edit"
      #   expect(page).to have_content "View" 
      # end

      # it "User is able to go BACK during a simple meta review." do
      #   stub_current_user(@submitter, @submitter.role.name, @submitter.role)
      #   visit '/student_task/list'
      #   expect(page).to have_content "metareview"
      #   click_link "TestAssignment"
      #   expect(page).to have_content "Others' work"
      #   click_link "Others' work"
      #   expect(page).to have_content 'Metareviews for "TestAssignment"'
      #   click_button "Request a new metareview to perform" 
      #   expect(page).to have_content "Begin"
      #   click_link "Begin"
      #   fill_in "responses[0][comment]", with: "Can you explain why this is garbage?"
      #   expect(page).to have_content "Back"
      #   click_link "Back"
      #   expect(page).to have_content "Update"
      #   expect(page).to have_content "View" 
      # end

      # it "If the metareview limit on the assignment is set to 3, then a student will see they need to submit 3 meta reviews" do
      #   stub_current_user(@submitter, @submitter.role.name, @submitter.role)
      #   visit '/student_task/list'
      #   expect(page).to have_content "metareview"
      #   click_link "TestAssignment"
      #   expect(page).to have_content "Others' work"
      #   click_link "Others' work"
      #   expect(page).to have_content 'Metareviews for "TestAssignment"'
      #   expect(page).to have_content 'Number of Meta-Reviews Allowed: "3"'
      # end

      # it "A student should see the number of meta-reviews decrement after a review is requested" do
      #   stub_current_user(@submitter, @submitter.role.name, @submitter.role)
      #   visit '/student_task/list'
      #   expect(page).to have_content "metareview"
      #   click_link "TestAssignment"
      #   expect(page).to have_content "Others' work"
      #   click_link "Others' work"
      #   expect(page).to have_content 'Metareviews for "TestAssignment"'
      #   expect(page).to have_content 'Number of Meta-Reviews Allowed: "3"'
      #   click_button "Request a new metareview to perform"
      #   expect(page).to have_content 'Number of Meta-Reviews left: 2'
      # end

      # it "A student should see the number of meta-reviews decrement after they complete a review" do
      #   stub_current_user(@submitter, @submitter.role.name, @submitter.role)
      #   visit '/student_task/list'
      #   expect(page).to have_content "metareview"
      #   click_link "TestAssignment"
      #   expect(page).to have_content "Others' work"
      #   click_link "Others' work"
      #   expect(page).to have_content 'Metareviews for "TestAssignment"'
      #   expect(page).to have_content 'Number of Meta-Reviews Allowed: "3"'
      #   click_button "Request a new metareview to perform"
      #   click_link "Begin"
      #   fill_in "responses[0][comment]", with: "Can you explain why this is garbage?"
      #   click_button "Save Metareview"
      #   expect(page).to have_content "Your response was successfully saved."
      #   expect(page).to have_content 'Number of Meta-Reviews left: 2'
      # end

      it "A student should not be able to request a metareview on their own reviews" do
        # The reviewer is the only one with an existing review, thus they should not be able to request a meta review on it.
        # Its assumed we are already loggedin as the reviewer.
        visit '/student_task/list'
        expect(page).to have_content "metareview"
        click_link "TestAssignment"
        expect(page).to have_content "Others' work"
        click_link "Others' work"
        expect(page).to have_content 'Metareviews for "TestAssignment"'
        expect(page).to have_content 'Meta-reviews cannot be performed at this time'
      end

      it "If the metareview limit on the assignment is set to 1 then a student should not be able to request a second meta review" do
        @assignment.num_metareviews_required = 1
        @assignment.num_metareviews_allowed = 1
        @assignment.save
        submit_metareview(@submitter)
        expect(page).to have_content 'Metareviews for "TestAssignment"'
        expect(page).to_not have_button "Request a new metareview to perform"
        expect(page).to have_content "Note: You can not do more than #{@assignment.num_metareviews_allowed} metareviews according to assignment policy."
      end
      
      it "User should not be able to see 'Request a new metareview to perfom' button when they have reviewed all valid reviews already" do
        submit_metareview(@submitter)
        expect(page).to have_content 'Metareviews for "TestAssignment"'
        expect(page).to_not have_button "Request a new metareview to perform"
        expect(page).to have_content 'Meta-reviews cannot be performed at this time'
      end
    end
    
    context "with a 4 reviewers." do
      before(:each) do
        # Create 4 reviews on the submitted assignment
        review_assignment("reviewer1", @assignment)
        review_assignment("reviewer2", @assignment)
        review_assignment("reviewer3", @assignment)
        review_assignment("reviewer4", @assignment)
        
        # Set the review due date so it has already passed.
        set_due_date(@review_due_date, Time.now - 1.day)
      end
      
      it "User should be able to click the 'Begin' button and still see 'Request a new metareview to perform' button" do
        stub_current_user(@submitter, @submitter.role.name, @submitter.role)
        visit '/student_task/list'
        expect(page).to have_content "metareview"
        click_link "TestAssignment"
        expect(page).to have_content "Others' work"
        click_link "Others' work"
        expect(page).to have_content 'Metareviews for "TestAssignment"'
        click_button "Request a new metareview to perform" 
        expect(page).to have_content "Begin"
        expect(page).to have_button "Request a new metareview to perform"
      end
      
      it "User should not be able to see 'Request a new metareview to perfom' button when they have reached the meta-review limit" do
        submit_metareview(@submitter)
        submit_metareview(@submitter)
        submit_metareview(@submitter)
        expect(page).to have_content "Note: You can not do more than #{@assignment.num_metareviews_allowed} metareviews according to assignment policy."
      end

      it "If a student has requested two metareviewes but have not submitted it, then they should not be able to request a new metareview." do
        stub_current_user(@submitter, @submitter.role.name, @submitter.role)
        visit '/student_task/list'
        expect(page).to have_content "metareview"
        click_link "TestAssignment"
        expect(page).to have_content "Others' work"
        click_link "Others' work"
        expect(page).to have_content 'Metareviews for "TestAssignment"'
        click_button "Request a new metareview to perform" 
        expect(page).to have_content "Begin"
        expect(page).to have_button "Request a new metareview to perform"
        click_button "Request a new metareview to perform" 
        expect(page).to have_content "Note: You can't have more than 2 outstanding meta-reviews. You must complete one of your outstanding meta-reviews before selecting another."
        expect(page).not_to have_button "Request a new metareview to perform"
      end

      it "A student should be able to request a metareview if they are above their required but below their allowed reviews" do
        @assignment.num_metareviews_required = 1
        @assignment.num_metareviews_allowed = 3
        @assignment.save
        submit_metareview(@submitter)
        submit_metareview(@submitter)
        expect(page).to have_content 'Metareviews for "TestAssignment"'
        expect(page).to have_button "Request a new metareview to perform"
      end
    end
  end
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
def review_assignment(name, assignment)
  # Set time so we are in the review stage
  set_due_date(@review_due_date, Time.now + 1.day)
  
  reviewer = create(:student, name: name)
  stub_current_user(reviewer, reviewer.role.name, reviewer.role)
  create(:participant, assignment: assignment, user: reviewer)
  visit '/student_task/list'
  expect(page).to have_content "review"
  click_link "TestAssignment"
  expect(page).to have_content "Others' work"
  click_link "Others' work"
  expect(page).to have_content 'Reviews for "TestAssignment"'
  click_button "Request a new submission to review"
  click_link "Begin"
  fill_in "responses[0][comment]", with: "This is a test review by #{reviewer.name}"
  click_button "Submit Review"
  expect(page).to have_content "Your response was successfully saved."
  
  # Set time so we are out of the review stage
  set_due_date(@review_due_date, Time.now - 1.day)
end

def submit_metareview(student)
  stub_current_user(student, student.role.name, student.role)
  visit '/student_task/list'
  expect(page).to have_content "metareview"
  click_link "TestAssignment"
  expect(page).to have_content "Others' work"
  click_link "Others' work"
  expect(page).to have_content 'Metareviews for "TestAssignment"'
  click_button "Request a new metareview to perform" 
  expect(page).to have_content "Begin"
  click_link "Begin"
  fill_in "responses[0][comment]", with: "This is a test metareview by #{student.name}"
  click_button "Submit Metareview"
  expect(page).to have_content "Your response was successfully saved." 
end

# Sets and saves the assignment due date
def set_due_date(assignment_due_date, time)
  assignment_due_date.due_at = time
  assignment_due_date.save
end

# Add meta-review parameters to the assignment that was defined first
def add_meta_review
  create(:deadline_type, name: "metareview")
  @metareview_due_date = create(:assignment_due_date,
                                deadline_type: DeadlineType.where(name: 'metareview').first,
                                due_at: Time.now + 3.day)
  # create a meta-review
  metareview = create(:questionnaire, name: "Metareview", type: "MetareviewQuestionnaire")
  create(:question, txt: "MetaReviewQuestion", questionnaire: metareview)
  create(:assignment_questionnaire, questionnaire: metareview, used_in_round: 1)
end