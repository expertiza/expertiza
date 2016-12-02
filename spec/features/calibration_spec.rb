require 'rails_helper'
require 'selenium-webdriver'

describe 'calibration' do
  # Before testing create needed state
  #before :each do
  it 'create data' do
#=begin
     #Create an instructor account
    @instructor = create :instructor
    create(:deadline_type, name: "submission")
    create(:deadline_type, name: "review")
    create(:deadline_type, name: "metareview")
    create(:deadline_type, name: "drop_topic")
    create(:deadline_type, name: "signup")
    create(:deadline_type, name: "team_formation")
    create(:deadline_right)
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')
#=end
  end

=begin
  # Test Assignment Creation Functionality
  describe 'Create Assignment' do

    # Test creating an assignment with calibration
    describe 'With Calibration' do
      # An assignment created with calibration turned on
      # should show the calibration tab when editing
      it 'should show calibration tab' do
        # Log in as the instructor.

        @instructor1 = User.find_by(name: 'instructor6')
        login_as @instructor1.name



        # Create a new assignment
        visit new_assignment_path

        # Populate form fields
        fill_in 'assignment_form_assignment_name', with: 'Calibration Test'
        fill_in 'assignment_form_assignment_directory_path', with: 'submission'
        check 'assignment_form_assignment_is_calibrated'

        # Submit
        click_button 'Create'

        # Verify Assignment Page
        expect(find('.assignments.edit > h1',:visible => false)).to have_content('Editing Assignment: Calibration Test')
        expect(page).to have_link('Calibration')
        if (Assignment.where(name:  'Calibration Test').first)
          (Assignment.where(name:  'Calibration Test')).destroy_all
        end
      end
    end

    # Test creating an assignment without calibration
    describe 'Without Calibration' do
      # An assignment created with calibration turned off
      # should not show the calibration tab when editing
      it 'Should not show the calibration tab' do
        # Log in as the instructor.

        @instructor1 = User.find_by(name: 'instructor6')
        login_as @instructor1.name


        # Create a new assignment
        visit new_assignment_path

        # Populate form fields, leaving calibration unchecked
        fill_in 'assignment_form_assignment_name', with: 'Calibration Test'
        fill_in 'assignment_form_assignment_directory_path', with: 'submission'

        # Submit
        click_button 'Create'

        # Verify Assignment Page
        expect(find('.assignments.edit > h1',:visible => false)).to have_content('Editing Assignment: Calibration Test')
        expect(page).to have_no_selector('#Calibration')
          if (Assignment.where(name:  'Calibration Test').first)
          (Assignment.where(name:  'Calibration Test')).destroy_all
        end
      end
    end
  end
=end
=begin
  # Test Assignment Edit Functionality
  describe 'Edit Assignment' do
    # Set up for testing
    #before :each do
    it 'create data' do
#=begin

      # Create an instructor and admin
      @admin = create(:admin)

      # Create an assignment with calibration
      @assignment = create :assignment,name: 'Edit_Assignment_Calibration', is_calibrated: true

      # Create a team linked to the calibrated assignment
      @team = create :assignment_team, name:'Edit_Assignment_Calibration_team1',assignment:Assignment.find_by(name:'Edit_Assignment_Calibration')

      # Create an assignment participant linked to the assignment.
      # The factory for this implicitly loads or creates a student
      # (user) object that the participant is linked to.
      @submitter = create :participant, assignment:Assignment.find_by(name:'Edit_Assignment_Calibration')

      # Create a mapping between the assignment team and the
      # participant object's user (the student).
      create :team_user, team: Team.find_by(name:'Edit_Assignment_Calibration_team1' ), user: @submitter.user
#=end
    end

    # Verify the calibration tab can be accessed by admins
    it 'calibration can be accessed by admins' do
      # Log in with the admin
      @admin1 = User.find_by(name: 'admin1')
      login_as @admin1.name

      @assignment1=Assignment.find_by(name:'Edit_Assignment_Calibration')
      # Visit the edit page
      visit edit_assignment_path @assignment1

      # Verify access to calibration
      expect(find('.assignments.edit > h1')).to have_content("Editing Assignment: #{@assignment1.name}")
      expect(page).to have_selector('#Calibration')
    end

    # Verify the calibration tab can be accessed by instructors
    it 'calibration can be accessed by instructors' do
      # Log in with the instructor
      @instructor = User.find_by(name: 'instructor6')
      login_as @instructor.name

      @assignment1=Assignment.find_by(name:'Edit_Assignment_Calibration')
      # Visit the edit page
      visit edit_assignment_path @assignment1

      # Verify access to calibration
      expect(find('.assignments.edit > h1')).to have_content("Editing Assignment: #{@assignment1.name}")
      expect(page).to have_selector('#Calibration')
    end

    # Verify that as submissions are made they appear in
    # the table under the calibration tab
    it 'shows artifacts that have been submitted' do
      # Log in with instructor
      @instructor = User.find_by(name: 'instructor6')
      login_as @instructor.name

      @assignment1=Assignment.find_by(name:'Edit_Assignment_Calibration')
      # Visit the edit page
      visit edit_assignment_path @assignment1

      # Click the Calibration Tab
      find('#Calibration').click

      # verify hyperlink exists
      expect(page).to have_link 'https://www.expertiza.ncsu.edu'
    end
  end
=end
=begin
  # Test Submitter Functionality
  describe 'Submitter' do
    # Set up for testing
    #before :each do
    it 'create data' do
      # Create an instructor and student
#=begin
      @student = create :student, name: 'student_calibration'
      @submitter1 = create :student,name: 'student_cali_sub1'

      # Create an assignment with calibration
      # Either course: nil is required or an AssignmentNode must also be created.
      # The page will not load if the assignment has a course but no mapping node.
      @assignment = create :assignment,name: 'Calibration_Submit_Test2', is_calibrated: true, instructor: User.find_by(name:'instructor6'), course: nil

      # Create an assignment due date
      create :assignment_due_date, due_at: (DateTime.now + 1), Assignment.find_by(name: 'Calibration_Submit_Test2')

      # Create a team linked to the calibrated assignment
      @team = create :assignment_team,name: 'Edit_Assignment_Calibration_team2', assignment: Assignment.find_by(name: 'Calibration_Submit_Test2')

      # Create an assignment participant linked to the assignment
      @participant = create :participant, assignment: Assignment.find_by(name: 'Calibration_Submit_Test2'), user: @submitter1

      # Create a mapping between the assignment team and the
      # participant object's user (the submitter).
      create :team_user, team: Team.find_by(name:'Edit_Assignment_Calibration_team2' ), user: @submitter
#=end
    end

    # Verify submitters can be added to the assignment
    it 'can be added to the assignment by login' do
      # Log in as the instructor
      @student_sub = User.find_by(name: 'student_calibration')
      Participant.where(handle: 'student_calibration').delete_all

      @instructor2 = User.find_by(name: 'instructor6')
      login_as @instructor2.name

      # Visit the add participant page
      @assignment_sub = Assignment.find_by(name: 'Calibration_Submit_Test2')
      visit "/participants/list?id=#{@assignment_sub.id}&model=Assignment"

      # Student is not already a participant

      expect(page).to have_no_link @student_sub.name

      # Add student as a submitter
      fill_in 'user_name', with: @student_sub.name
      choose 'user_role_submitter'
      click_on 'Add'

      # Verify the submitter is listed
      expect(page).to have_link @student_sub.name
    end

    # Verify submitters can submit artifacts
    it 'can submit artifacts for calibration' do
      # Log in as student
      @submitter_1 = Student.find_by(name: 'student_cali_sub1')
      login_as @submitter_1.name

      # Click on the assignment link, and navigate to work view
      @assignment_sub = Assignment.find_by(name: 'Calibration_Submit_Test2')
      click_link @assignment_sub.name
      click_link 'Your work'

      # Fill in submission with a url and submit
      fill_in 'submission', with: 'https://www.google.com'
      click_on 'Upload link'

      # Verify presense of link on page
      expect(page).to have_link 'https://www.google.com'
    end
  end
=end
#=begin
  # test expert review function
  describe 'Add Expert Review' do
    #before :each do
    it 'create data' do
      # create instructor
      @student = create(:student,name: 'Add_expert_cali_student')

      @questionnaire = create(:questionnaire,name: 'Add_expert_cali_quesnair')

      # Create an assignment with calibration
      @assignment = create :assignment,name: 'Add_expert_cali_assignment', is_calibrated: true
      @assignment_questionnaire = create :assignment_questionnaire, assignment: @assignment

      # Create a team linked to the calibrated assignment
      @team = create :assignment_team,name: 'Add_expert_cali_team', assignment: @assignment

      # Create an assignment participant linked to the assignment.
      # The factory for this implicitly loads or creates a student
      # (user) object that the participant is linked to.
      @submitter = create :participant, assignment: @assignment
      # Create a mapping between the assignment team and the
      # participant object's user (the student).
      create :team_user, team: @team, user: @submitter.user
      create :review_response_map, assignment: @assignment, reviewee: @team
      # create :assignment_questionnaire, assignment: @assignment
    end

    it 'should be able to save an expert review without uploading', js: true do
      # Log in as the instructor.
      @instructor_add=User.find_by(name: 'instructor6')
      login_as @instructor_add.name

      # should be able to edit assignment to add a expert review
      @assignment_add = Assignment.find_by(name: 'Add_expert_cali_assignment')
      @team_add=Team.find_by(name: 'Add_expert_cali_team')
      visit "/review_mapping/add_calibration/#{@assignment_add.id}?team_id=#{@team_add.id}"
      # submit expert review
      click_on 'Submit Review'
      page.driver.browser.switch_to.alert.accept
      # expect result
      # If the review was uploaded, there will be a edit link
      expect(page).to have_content('Editing Assignment: Add_expert_cali_assignment')

    end

    # Student should not be able to submit an expert review
    it 'student should not be able to add an expert review', js: true do
      # login as student
      @student_add = Student.find_by(name: 'Add_expert_cali_student')
      login_as @student_add.name

      # Should not be able to visit expert review page
      @assignment_add = Assignment.find_by(name: 'Add_expert_cali_assignment')
      @team_add=Team.find_by(name: 'Add_expert_cali_team')
      visit "/review_mapping/add_calibration/#{@assignment_add.id}?team_id=#{@team_add.id}"
      # Expect result
      expect(page).to have_content('A student is not allowed to add_calibration this/these review_mapping')
    end
  end

  def create_fill_questionnaire
    # login as instructor
    login_as @instructor.name

    # go to the questionnaire creation page
    visit "/questionnaires/new?model=ReviewQuestionnaire&private=0"

    fill_in 'questionnaire_name', with: @questionnaire_name
    click_on('Create')

    # page fails here, asks for questions to put into the questionnaire
    click_on('Add')
    # name the question
    fill_in 'question[1][txt]', with: 'question_1'
    # save the questionnaire
    click_on('Save review questionnaire')

    expect(page).to have_content('All questions has been successfully saved!')

    # go to the assignment edit page
    visit "/assignments/#{@assignment.id}/edit"
    # edit_assignment_path @assignment

    # click_on Rubrics
    click_on("Rubrics")
    # assign the questionnaire to the assignment
    select @questionnaire_name
    # click on review strategy
    click_on("Review strategy")
    # set review limit from 0 to 1
    fill_in 'assignment_form[assignment][review_topic_threshold]', with: '1'

    click_on("Due dates")
    within('#review_round_1') do
      select 'Yes', from: "assignment_form[due_date][][submission_allowed_id]"
    end
    # have to save the questionnaire assignment
    click_on("Save")

    # start the calibration
    # click_link('Begin')
    visit "/review_mapping/add_calibration/#{@assignment.id}?team_id=#{@team2.id}"
    # even though you can't see anything, don't worry, the option is actually there. everything will render once the next command runs
    # select the dropdown option. believe in the heart of the cards!
    select '5-Strongly agree'
    # submit review
    click_on "Submit Review"
    # click ok on the pop-up box that warns you that responses can not be edited
    page.driver.browser.switch_to.alert.accept
  end
#=end
=begin
  # test display calibration
  describe 'Display Calibration For Student' do
    #before :each do
      it 'create data' do
=begin
      # create instructor
      @student2 = create(:student,name: 'Display_cali_stu2')
      @student = create(:student,name: 'Display_cali_stu')

      @questionnaire_name = 'calibration_questionnaire'
      # Create an assignment with calibration
      # Either course: nil is required or an AssignmentNode must also be created.
      # The page will not load if the assignment has a course but no mapping node.
      @assignment = create :assignment,name: 'Display_cali_ass', is_calibrated: true, instructor: User.find_by(name: 'instructor6'), course: nil

      # Create an assignment due date
      create :assignment_due_date, due_at: (DateTime.now - 1),assignment:Assignment.find_by(name: 'Display_cali_ass')

      @review_deadline_type = create(:deadline_type, name: "review")
      create :assignment_due_date, due_at: (DateTime.now + 1), deadline_type: @review_deadline_type,assignment:Assignment.find_by(name: 'Display_cali_ass')

      # Create a team linked to the calibrated assignment
      @team = create :assignment_team, name: 'Display_cali_team', assignment: Assignment.find_by(name: 'Display_cali_ass')

      # Create an assignment participant linked to the assignment
      @participant = create :participant, assignment: Assignment.find_by(name: 'Display_cali_ass'), user: Student.find_by(name: 'Display_cali_stu')

      # Create a mapping between the assignment team and the
      # participant object's user (the submitter).
      create :team_user, team: Team.find_by(name: 'Display_cali_team'), user: Student.find_by(name: 'Display_cali_stu')
      # create :review_response_map, assignment: @assignment, reviewee: @team

      # Create a team linked to the calibrated assignment
      @team2 = create :assignment_team,name:'Display_cali_team2', assignment: Assignment.find_by(name: 'Display_cali_ass')

      # Create an assignment participant linked to the assignment
      @participant2 = create :participant, assignment: Assignment.find_by(name: 'Display_cali_ass'), user: Student.find_by(name: 'Display_cali_stu2')

      # Create a mapping between the assignment team and the
      # participant object's user (the submitter).
      create :team_user, team: Team.find_by(name:'Display_cali_team2'), user: Student.find_by(name: 'Display_cali_stu2')
      # create :review_response_map, assignment: @assignment, reviewee: @team2

      # creating the questionnaire and then linking it to the assignment.
      @questionnaire = create :questionnaire,name: 'Display_cali_quesnaire'
      @assignment_questionnaire = create :assignment_questionnaire, assignment:  Assignment.find_by(name: 'Display_cali_ass'), questionnaire: Questionnaire.find_by(name: 'Display_cali_quesnaire')
#=end
  end

    # creates a questionnaire, assigns it to the assignment, fills out the questionaire,
    # displays the questionaire response, checks to make sure the score is there
    xit 'create a questionnaire, fill it out, display results', js: true do
      create_fill_questionnaire
      # REVIEW: should be submitted at this point. click on view to make sure you can see it
      # click_link "View"
      @assignment_ds =  Assignment.find_by(name: 'Display_cali_ass')
      visit "/response/view?id=#{@assignment_ds.id}&return=assignment_edit"
      # REVIEW: is hidden by default, click on show review to show your review.
      click_on "show review"
      # once you click show review, the score label comes up as well as some other fields.
      # Removing this check since this text is removed in Pull 678
      expect(page).to have_content('5')

      # login as student2066
      user = User.find_by_name('student2066')
      stub_current_user(user, user.role.name, user.role)

      # go to the assignment page and request a review
      visit "/menu/student_task"
      click_on "final2"
      expect(page).to have_content('')

      click_on "Others' work"
      click_on "Request a new submission to review"
      click_on "Begin"
      select '4'
      # submit review
      click_on "Submit Review"
      # click ok on the pop-up box that warns you that responses can not be edited
      page.driver.browser.switch_to.alert.accept
      # the review should now be avaliable, now click on begin.

      click_on "Show calibration results"
      expect(page).to have_content('Expert review')
      expect(page).to have_content('5')
      expect(page).to have_content('Your review')
      expect(page).to have_content('4')
    end
  end
=end
=begin
  describe 'Reviewer' do
    # Set up for testing
    #before :each do
    it 'create data' do
#=begin
      # Create an instructor and 3 students
      @student = create :student,name: 'Cali_Reviewer_student'
      @nonreviewer = create :student,name:'Cali_Reviewer_nonstudent'
      @submitter = create :student,name: 'Cali_Review_submitter'

      # Create an assignment with calibration
      # Either course: nil is required or an AssignmentNode must also be created.
      # The page will not load if the assignment has a course but no mapping node.
      @assignment = create :assignment,name: 'Cali_Reviewer_ass', is_calibrated: true, instructor: User.find_by(name:'instructor6'), course: nil

      # Create an assignment due date
      create :assignment_due_date, due_at: (DateTime.now - 1)
      @review_deadline_type = create(:deadline_type, name: "review")
      create :assignment_due_date, due_at: (DateTime.now + 1), deadline_type: @review_deadline_type
      # Create a team linked to the calibrated assignment
      @team = create :assignment_team,name: 'Cali_Reviewer_team', assignment: Assignment.find_by(name: 'Cali_Reviewer_ass')

      # Create an assignment participant linked to the assignment
      @participant_submitter = create :participant, assignment: Assignment.find_by(name: 'Cali_Reviewer_ass'), user: Student.find_by(name: 'Cali_Review_submitter')
      @participant_reviewer = create :participant, assignment: Assignment.find_by(name: 'Cali_Reviewer_ass'), user: Student.find_by(name: 'Cali_Reviewer_nonstudent')
      @participant_reviewer_2 = create :participant, assignment: Assignment.find_by(name: 'Cali_Reviewer_ass'), user: Student.find_by(name: 'Cali_Reviewer_student')

      # Create a mapping between the assignment team and the
      # participant object's user.
      create :team_user, team: Team.find_by(name: 'Cali_Reviewer_team'), user: Student.find_by(name: 'Cali_Reviewer_nonstudent')

      # Create and map a questionnaire (rubric) to the assignment
      @questionnaire = create :questionnaire ,name: 'Cali_Reviewer_quesnaire'
      create :question, questionnaire: Questionnaire.find_by(name: 'Cali_Reviewer_quesnaire')
      create :assignment_questionnaire, assignment: Assignment.find_by(name: 'Cali_Reviewer_ass'), questionnaire: Questionnaire.find_by(name: 'Cali_Reviewer_quesnaire')
      create :review_response_map, assignment: Assignment.find_by(name: 'Cali_Reviewer_ass'), reviewee: Team.find_by(name: 'Cali_Reviewer_team')
#=end
    end
#=begin
    it'instructor should be able to assign artifact to reviewer', js: true do
      # Log in as an instructor
      @instructor4 = User.find_by(name: 'instructor6')
      login_as @instructor4.name

      # Edit assignment route
      @assignment_care= Assignment.find_by(name: 'Cali_Reviewer_ass')
      ReviewResponseMap.where(reviewed_object_id: @assignment_care.id).delete_all
      ReviewResponseMap.all.destroy_all
      visit edit_assignment_path @assignment_care

      click_on('Review strategy')

      # Choose the option for instructor to assign student to review artifacts
      page.select 'Instructor-Selected', from: 'assignment_form_assignment_review_assignment_strategy'

      # Assign reviewer
      click_on('Assign reviewers')

      # Add students to review one artifacts
      click_on('add reviewer')

      # Go to the page where instructor can add student to one artifact
      @team_care =Team.find_by(name: 'Cali_Reviewer_team')
      visit "/review_mapping/select_reviewer?contributor_id=#{@team_care.id}&id=#{@assignment_care.id}"

      # Input the student's name for the review
      @student_care = Student.find_by(name: 'Cali_Reviewer_student')
      fill_in 'user_name', with: @student_care.name

      # Add reviewer
      click_on 'Add Reviewer'

      # Verify the student has been assigned to the artifact
      expect(page).to have_content @student_care.name
      ReviewResponseMap.all.destroy_all
      @assignment_care.update_attributes(num_reviews: 0,num_review_of_reviews: 0,num_review_of_reviewers: 0)
    end
#=end
    # Verify submitters can submit artifacts
    it 'can review artifacts', js: true do
      # Log in as student
      @student_care = Student.find_by(name: 'Cali_Reviewer_student')
      login_as @student_care.name
      ReviewResponseMap.all.destroy_all
      # Click on the assignment link, and navigate to work view
      @assignment_care= Assignment.find_by(name: 'Cali_Reviewer_ass')
      click_link @assignment_care.name
      @assignment_care.update_attributes(num_reviews: 0,num_review_of_reviews: 0,num_review_of_reviewers: 0)
      # Be able to review others' work
      click_link 'Others\' work'

      # Click_link 'Request a new submission to review'
      click_on "Request a new submission to review"

      # Be able to start a review
      expect(page).to have_link 'Begin'
    end
    it 'can not review artifacts if not a assigned a review', js: true do
      # Log in as a student who hasn't been assigned a artifact to review
      @nonreviewer_care =Student.find_by(name: 'Cali_Reviewer_nonstudent')
      login_as @nonreviewer_care.name
      ReviewResponseMap.all.destroy_all

      # Click on the assignment link, and navigate to work view
      @assignment_care= Assignment.find_by(name: 'Cali_Reviewer_ass')
      click_link @assignment_care.name
      @assignment_care.update_attributes(num_reviews: 0,num_review_of_reviews: 0,num_review_of_reviewers: 0)
      # Be able to review others' work
      click_link 'Others\' work'

      # Click_link 'Request a new submission to review'
      click_on "Request a new submission to review"

      # Do not have any artifacts to review
      expect(page).to have_content("No artifact are available to review at this time. Please try later.")
    end
  end
=end
end
