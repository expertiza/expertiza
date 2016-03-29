# TODO write quiz tests
require 'rails_helper'
describe "quiz testing", :type => :feature do
  # Set up for testing
  before(:each) do
    # Create an instructor and admin
      @instructor = create(:instructor)

      # Create an assignment with quiz
      @assignment = create :assignment, require_quiz: true

      # Create a team linked to the calibrated assignment
      @team = create :assignment_team, assignment: @assignment

      # Create an assignment participant linked to the assignment.
      # The factory for this implicitly loads or creates a student
      # (user) object that the participant is linked to.
      @submitter = create :participant, assignment: @assignment

      # Create a mapping between the assignment team and the
      # participant object's user (the student).
      create :team_user, team: @team, user: @submitter.user
    end

#The instructor can set up an assignment which supports quizzing feature by
#Checking the “has quiz” box
#Setting the # of question for each set of quiz
#Setting in which deadline can student reviewers take the quizzes
  it "instructor can set up assignment" do
    # Log in with the instructor
    login_as @instructor.name

    # Visit the edit page
    visit edit_assignment_path @assignment

    # Verify access to quiz
  end


end