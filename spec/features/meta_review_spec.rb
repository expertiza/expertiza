require 'pry'

describe "meta review user tests" do
    before(:each) do
      # create an assignment. Defaults to 3 metareviews required and allowed.
      # See spec/factories/factories.rb  factory :assignment for more details on defaults.
      assignment = create(:assignment,
                           name: "TestAssignment",
                           directory_path: 'test_assignment')
      
      # create a reivew
      reivew = create(:questionnaire, name: "Review")
      create(:question, txt: "Question1", questionnaire: reivew, type: "Criterion")
      create(:assignment_questionnaire, questionnaire: reivew, used_in_round: 1)
      
      # populate deadline type
      create(:deadline_type, name: "submission")
      create(:deadline_type, name: "review")
      create(:deadline_type, name: "metareview")
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')

      # populate assignment deadline
      submission_due_date = create(:assignment_due_date,
                                    deadline_type: DeadlineType.where(name: 'submission').first,
                                    due_at: Time.now + 1.day)
      review_due_date = create(:assignment_due_date,
                                deadline_type: DeadlineType.where(name: 'review').first,
                                due_at: Time.now + 2.day)
      metareview_due_date = create(:assignment_due_date,
                                    deadline_type: DeadlineType.where(name: 'metareview').first,
                                    due_at: Time.now + 3.day)

      # add participants to assignment
      submitter = create(:student, name: 'submit_and_meta_student')
      reviewer = create(:student, name: 'review_student')
      create(:participant, assignment: assignment, user: submitter)
      create(:participant, assignment: assignment, user: reviewer)

      # The first student submits an assigment to be reviewed.
      submit_assignment(submitter)
      
      # Pull submission due date back so it has already passed.
      submission_due_date.due_at = Time.now - 1.day
      submission_due_date.save
      
      # The second reviewer reviews the submitted assignment
      review_assignment(reviewer)

      # Pull review due date back so it has already passed.
      review_due_date.due_at = Time.now - 1.day
      review_due_date.save

      # We are now setup for the meta review tests.
    end

  # impersonate student to submit work
  def submit_assignment(user)
    stub_current_user(user, user.role.name, user.role)
    visit '/student_task/list'
    click_link "TestAssignment"
    click_link "Your work"
    fill_in 'submission', with: "https://ncsu.edu"
    click_on 'Upload link'
    expect(page).to have_content "https://ncsu.edu"
  end

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
  end