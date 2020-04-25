describe "Meta-review tests" do
  # In order to test the meta-review functionality as a user an assignment needs to have passed
  # the submission and review deadlines. It also requires two actors.
  #   1. The submitter is responsible for submitting the assignment and is the actor who
  #      is capable of completing a meta review.
  #   2. The reviewer is used to review the submitters submission.
  before(:each) do
    # Create an assignment.
    # See spec/factories/factories.rb  factory :assignment for more details on defaults.
    @assignment = create(:assignment,
                         name: "TestAssignment",
                         directory_path: 'test_assignment',
                         num_metareviews_allowed: 5,
                         num_metareviews_required: 3)

    # Create a review
    review = create(:questionnaire, name: "Review")
    create(:question, txt: "ReviewQuestion1", questionnaire: review)
    create(:assignment_questionnaire, questionnaire: review, used_in_round: 1)

    # Populate deadline type                 id
    create(:deadline_right, name: 'No')    # 1
    create(:deadline_right, name: 'Late')  # 2
    create(:deadline_right, name: 'OK')    # 3

    # Populate assignment deadlines
    @submission_due_date = create(:assignment_due_date,
                                  deadline_type: create(:deadline_type, name: "submission"),
                                  submission_allowed_id: 3,        # OK
                                  review_allowed_id: 1,            # No
                                  review_of_review_allowed_id: 1)  # No
    @review_due_date = create(:assignment_due_date,
                              deadline_type: create(:deadline_type, name: "review"),
                              submission_allowed_id: 1,            # No
                              review_allowed_id: 3,                # OK
                              review_of_review_allowed_id: 1)      # No

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
      
      it "User should NOT be able to see 'Request a new meta-review to perfom' button when there are no reviews available" do
        stub_current_user(@submitter, @submitter.role.name, @submitter.role)
        visit '/student_task/list'
        expect(page).to have_content "metareview"
        click_link "TestAssignment"
        expect(page).to have_content "Others' work"
        click_link "Others' work"
        expect(page).to have_content 'Meta-reviews for "TestAssignment"'
        expect(page).to_not have_button "Request a new meta-review to perform"
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
      
      it "User is able to SAVE a simple meta-review." do
        stub_current_user(@submitter, @submitter.role.name, @submitter.role)
        visit '/student_task/list'
        expect(page).to have_content "metareview"
        click_link "TestAssignment"
        expect(page).to have_content "Others' work"
        click_link "Others' work"
        expect(page).to have_content 'Meta-reviews for "TestAssignment"'
        click_button "Request a new meta-review to perform"
        expect(page).to have_content "Begin"
        click_link "Begin"
        fill_in "responses[0][comment]", with: "Can you explain why this is garbage?"
        click_button "Save Metareview"
        expect(page).to have_content "Your response was successfully saved."


        # We should see 'Edit' Because we are in the current round of the review.
        expect(page).to have_content "Edit"
        expect(page).to have_content "View"
      end

      it "User is able to go BACK during a simple meta review." do
        stub_current_user(@submitter, @submitter.role.name, @submitter.role)
        visit '/student_task/list'
        expect(page).to have_content "metareview"
        click_link "TestAssignment"
        expect(page).to have_content "Others' work"
        click_link "Others' work"
        expect(page).to have_content 'Meta-reviews for "TestAssignment"'
        click_button "Request a new meta-review to perform"
        expect(page).to have_content "Begin"
        click_link "Begin"
        fill_in "responses[0][comment]", with: "Can you explain why this is garbage?"
        expect(page).to have_content "Back"
      end

      it "When the limit and required number of meta-reviews on the assignment are equal, 
          then a student will see they need to submit exactly that number of meta-reviews" do
        set_metareview_limits(3,3)
        
        stub_current_user(@submitter, @submitter.role.name, @submitter.role)
        visit '/student_task/list'
        expect(page).to have_content "metareview"
        click_link "TestAssignment"
        expect(page).to have_content "Others' work"
        click_link "Others' work"
        expect(page).to have_content 'Meta-reviews for "TestAssignment"'
        expect(page).to have_content "You should perform exactly #{@assignment.num_metareviews_required} meta-reviews"
      end

      it "When the limit and required number of meta-reviews on the assignment are equal, 
          then a student will see they need to submit exactly that number of meta-reviews" do
        set_metareview_limits(3,3)
        
        stub_current_user(@submitter, @submitter.role.name, @submitter.role)
        visit '/student_task/list'
        expect(page).to have_content "metareview"
        click_link "TestAssignment"
        expect(page).to have_content "Others' work"
        click_link "Others' work"
        expect(page).to have_content 'Meta-reviews for "TestAssignment"'
        expect(page).to have_content "You should perform exactly #{@assignment.num_metareviews_required} meta-reviews"
      end

      it "When the meta-review limits for an assignment are unset then a student will see
          that the number of meta-reviews aren't limited" do

        set_metareview_limits(-1,-1)

        stub_current_user(@submitter, @submitter.role.name, @submitter.role)
        visit '/student_task/list'
        expect(page).to have_content "metareview"
        click_link "TestAssignment"
        expect(page).to have_content "Others' work"
        click_link "Others' work"
        expect(page).to have_content 'Meta-reviews for "TestAssignment"'
        expect(page).not_to have_content "Number of meta-reviews left:"
        expect(page).not_to have_content "You are required to do #{@assignment.num_metareviews_required} meta-reviews"
      end

      it "A student should not see a number of required or allowed meta-reviews when there are no limits on meta-reviews" do

        set_metareview_limits(-1,-1)

        stub_current_user(@submitter, @submitter.role.name, @submitter.role)
        visit '/student_task/list'
        expect(page).to have_content "metareview"
        click_link "TestAssignment"
        expect(page).to have_content "Others' work"
        click_link "Others' work"
        expect(page).to have_content 'Meta-reviews for "TestAssignment"'
        expect(page).to have_content "Your instructor has made meta-reviews optional. You are not required to complete any meta-reviews"
        expect(page).to have_content "There is no limit on the number of meta-reviews you may complete."
      end

      it "A student should see the number of meta-reviews decrement after a review is requested" do
        stub_current_user(@submitter, @submitter.role.name, @submitter.role)
        visit '/student_task/list'
        expect(page).to have_content "metareview"
        click_link "TestAssignment"
        expect(page).to have_content "Others' work"
        click_link "Others' work"
        expect(page).to have_content 'Meta-reviews for "TestAssignment"'
        expect(page).to have_content "Number of meta-reviews left: #{@assignment.num_metareviews_allowed}"
        click_button "Request a new meta-review to perform"
        expect(page).to have_content "Number of meta-reviews left: #{@assignment.num_metareviews_allowed - 1}"
      end

      it "A student should see the number of meta-reviews decrement after they complete a review" do
        stub_current_user(@submitter, @submitter.role.name, @submitter.role)
        visit '/student_task/list'
        expect(page).to have_content "metareview"
        click_link "TestAssignment"
        expect(page).to have_content "Others' work"
        click_link "Others' work"
        expect(page).to have_content 'Meta-reviews for "TestAssignment"'
        expect(page).to have_content "Number of meta-reviews left: #{@assignment.num_metareviews_allowed}"
        click_button "Request a new meta-review to perform"
        click_link "Begin"
        fill_in "responses[0][comment]", with: "Can you explain why this is garbage?"
        click_button "Save Metareview"
        expect(page).to have_content "Your response was successfully saved."
        expect(page).to have_content "Number of meta-reviews left: #{@assignment.num_metareviews_allowed - 1}"
      end

      it "A student should not be able to request a meta-review on their own reviews" do
        # The reviewer is the only one with an existing review, thus they should not be able to request a meta review on it.
        # Its assumed we are already loggedin as the reviewer.
        visit '/student_task/list'
        expect(page).to have_content "metareview"
        click_link "TestAssignment"
        expect(page).to have_content "Others' work"
        click_link "Others' work"
        expect(page).to have_content 'Meta-reviews for "TestAssignment"'
        expect(page).to have_content 'Meta-reviews cannot be performed at this time'
      end

      it "If the meta-review limit on the assignment is set to 1 then a student should not be able to request a second meta review" do
        set_metareview_limits(1,1)
        
        submit_metareview(@submitter)
        expect(page).to have_content 'Meta-reviews for "TestAssignment"'
        expect(page).to_not have_button "Request a new meta-review to perform"
        expect(page).to have_content "Note: You can not do more than #{@assignment.num_metareviews_allowed} meta-reviews according to assignment policy."
      end
      
      it "User should not be able to see 'Request a new meta-review to perfom' button when they have reviewed all valid reviews already" do
        submit_metareview(@submitter)
        expect(page).to have_content 'Meta-reviews for "TestAssignment"'
        expect(page).to_not have_button "Request a new meta-review to perform"
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
      
      it "User should be able to click the 'Begin' button and still see 'Request a new meta-review to perform' button" do
        stub_current_user(@submitter, @submitter.role.name, @submitter.role)
        visit '/student_task/list'
        expect(page).to have_content "metareview"
        click_link "TestAssignment"
        expect(page).to have_content "Others' work"
        click_link "Others' work"
        expect(page).to have_content 'Meta-reviews for "TestAssignment"'
        click_button "Request a new meta-review to perform"
        expect(page).to have_content "Begin"
        expect(page).to have_button "Request a new meta-review to perform"
      end
      
      it "User should not be able to see 'Request a new meta-review to perfom' button when they have reached the meta-review limit" do
        set_metareview_limits(3,3)
        
        submit_metareview(@submitter)
        submit_metareview(@submitter)
        submit_metareview(@submitter)
        expect(page).to have_content "Note: You can not do more than #{@assignment.num_metareviews_allowed} meta-reviews according to assignment policy."
      end

      it "If a student has requested two meta-reviewes but have not submitted it, then they should not be able to request a new meta-review." do
        stub_current_user(@submitter, @submitter.role.name, @submitter.role)
        visit '/student_task/list'
        expect(page).to have_content "metareview"
        click_link "TestAssignment"
        expect(page).to have_content "Others' work"
        click_link "Others' work"
        expect(page).to have_content 'Meta-reviews for "TestAssignment"'
        click_button "Request a new meta-review to perform"
        expect(page).to have_content "Begin"
        expect(page).to have_button "Request a new meta-review to perform"
        click_button "Request a new meta-review to perform"
        expect(page).to have_content "Note: You can't have more than 2 outstanding meta-reviews. You must complete one of your outstanding meta-reviews before selecting another."
        expect(page).not_to have_button "Request a new meta-review to perform"
      end

      it "A student should be able to request a meta-review if they are above their required but below their allowed reviews" do
        set_metareview_limits(3,1)
        
        submit_metareview(@submitter)
        submit_metareview(@submitter)
        expect(page).to have_content 'Meta-reviews for "TestAssignment"'
        expect(page).to have_button "Request a new meta-review to perform"
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
  expect(page).to have_content 'Meta-reviews for "TestAssignment"'
  click_button "Request a new meta-review to perform"
  expect(page).to have_content "Begin"
  click_link "Begin"
  fill_in "responses[0][comment]", with: "This is a test meta-review by #{student.name}"
  click_button "Submit Metareview"
  expect(page).to have_content "Your response was successfully saved." 
end

# Sets and saves the assignment due date
def set_due_date(assignment_due_date, time)
  assignment_due_date.due_at = time
  assignment_due_date.save
end

# Sets and saves the meta review limits on an assignment
def set_metareview_limits(allowed, required)
  @assignment.num_metareviews_allowed = allowed
  @assignment.num_metareviews_required = required
  @assignment.save
end

# Add meta-review parameters to the assignment that was defined first
def add_meta_review
  
  @metareview_due_date = create(:assignment_due_date,
                                deadline_type: create(:deadline_type, name: "metareview"),
                                submission_allowed_id: 1,         # No
                                review_allowed_id: 1,             # No
                                review_of_review_allowed_id: 3)   # OK
  # create a meta-review
  metareview = create(:questionnaire, name: "Metareview", type: "MetareviewQuestionnaire")
  create(:question, txt: "MetaReviewQuestion", questionnaire: metareview)
  create(:assignment_questionnaire, questionnaire: metareview)
end