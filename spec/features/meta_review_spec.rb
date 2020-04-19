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
    create(:question, txt: "Question1", questionnaire: reivew)
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
    submitter = create(:student, name: 'submit_and_meta_student')
    reviewer = create(:student, name: 'review_student')
    create(:participant, assignment: assignment, user: submitter)
    create(:participant, assignment: assignment, user: reviewer)

    # The submitter submits an assigment to be reviewed.
    submit_assignment(submitter)

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

    it "Student is able to leave a simple meta review." do
      
    end
  # Add meta-review parameters to the assignment that was defined first
  def add_meta_review
    create(:deadline_type, name: "metareview")
    create(:assignment_due_date,
           deadline_type: DeadlineType.where(name: 'metareview').first,
           due_at: Time.now + 3.day)
    # create a meta-review
    reivew = create(:questionnaire, name: "Review")
    create(:question, txt: "Question1", questionnaire: reivew)
    create(:assignment_questionnaire, questionnaire: reivew, used_in_round: 1)
  end
end