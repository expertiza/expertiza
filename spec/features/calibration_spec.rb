require 'rails_helper'
require 'selenium-webdriver'

describe 'calibration' do
  # Before testing create needed state
  before :each do
    # Create an instructor account
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
  end

  # Test Assignment Creation Functionality
  describe 'Create Assignment' do

    # Test creating an assignment with calibration
    describe 'With Calibration' do
      # An assignment created with calibration turned on
      # should show the calibration tab when editing
      it 'should show calibration tab' do
        # Log in as the instructor.
        login_as @instructor.name

        # Create a new assignment
        visit new_assignment_path

        # Populate form fields
        fill_in 'assignment_form_assignment_name', with: 'Calibration Test'
        fill_in 'assignment_form_assignment_directory_path', with: 'submission'
        check 'assignment_form_assignment_is_calibrated'

        # Submit
        click_button 'Create'

        # Verify Assignment Page
        expect(find('.assignments.edit > h1')).to have_content('Editing Assignment: Calibration Test')
        expect(page).to have_link('Calibration')
      end
    end

    # Test creating an assignment without calibration
    describe 'Without Calibration' do
      # An assignment created with calibration turned off
      # should not show the calibration tab when editing
      it 'Should not show the calibration tab' do
        # Log in as the instructor.
        login_as @instructor.name

        # Create a new assignment
        visit new_assignment_path

        # Populate form fields, leaving calibration unchecked
        fill_in 'assignment_form_assignment_name', with: 'Calibration Test'
        fill_in 'assignment_form_assignment_directory_path', with: 'submission'

        # Submit
        click_button 'Create'

        # Verify Assignment Page
        expect(find('.assignments.edit > h1')).to have_content('Editing Assignment: Calibration Test')
        expect(page).to have_no_selector('#Calibration')
      end
    end
  end

  # Test Assignment Edit Functionality
  describe 'Edit Assignment' do
    # Set up for testing
    before :each do
      # Create an instructor and admin
      @admin = create(:admin)

      # Create an assignment with calibration
      @assignment = create :assignment, is_calibrated: true

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

    # Verify the calibration tab can be accessed by admins
    it 'calibration can be accessed by admins' do
      # Log in with the admin
      login_as @admin.name

      # Visit the edit page
      visit edit_assignment_path @assignment

      # Verify access to calibration
      expect(find('.assignments.edit > h1')).to have_content("Editing Assignment: #{@assignment.name}")
      expect(page).to have_selector('#Calibration')
    end

    # Verify the calibration tab can be accessed by instructors
    it 'calibration can be accessed by instructors' do
      # Log in with the instructor
      login_as @instructor.name

      # Visit the edit page
      visit edit_assignment_path @assignment

      # Verify access to calibration
      expect(find('.assignments.edit > h1')).to have_content("Editing Assignment: #{@assignment.name}")
      expect(page).to have_selector('#Calibration')
    end

    # Verify that as submissions are made they appear in
    # the table under the calibration tab
    it 'shows artifacts that have been submitted' do
      # Log in with instructor
      login_as @instructor.name

      # Visit the edit page
      visit edit_assignment_path @assignment

      # Click the Calibration Tab
      find('#Calibration').click

      # verify hyperlink exists
      expect(page).to have_link 'https://www.expertiza.ncsu.edu'
    end
  end

  # Test Submitter Functionality
  describe 'Submitter' do
    # Set up for testing
    before :each do
      # Create an instructor and student
      @student = create :student
      @submitter = create :student

      # Create an assignment with calibration
      # Either course: nil is required or an AssignmentNode must also be created.
      # The page will not load if the assignment has a course but no mapping node.
      @assignment = create :assignment, is_calibrated: true, instructor: @instructor, course: nil

      # Create an assignment due date
      create :assignment_due_date, due_at: (DateTime.now + 1)

      # Create a team linked to the calibrated assignment
      @team = create :assignment_team, assignment: @assignment

      # Create an assignment participant linked to the assignment
      @participant = create :participant, assignment: @assignment, user: @submitter

      # Create a mapping between the assignment team and the
      # participant object's user (the submitter).
      create :team_user, team: @team, user: @submitter
    end

    # Verify submitters can be added to the assignment
    it 'can be added to the assignment by login' do
      # Log in as the instructor
      login_as @instructor.name

      # Visit the add participant page
      visit "/participants/list?id=#{@assignment.id}&model=Assignment"

      # Student is not already a participant
      expect(page).to have_no_link @student.name

      # Add student as a submitter
      fill_in 'user_name', with: @student.name
      choose 'user_role_submitter'
      click_on 'Add'

      # Verify the submitter is listed
      expect(page).to have_link @student.name
    end

    # Verify submitters can submit artifacts
    it 'can submit artifacts for calibration' do
      # Log in as student
      login_as @submitter.name

      # Click on the assignment link, and navigate to work view
      click_link @assignment.name
      click_link 'Your work'

      # Fill in submission with a url and submit
      fill_in 'submission', with: 'https://google.com'
      click_on 'Upload link'

      # Verify presense of link on page
      expect(page).to have_link 'https://google.com'
    end
  end

  # test expert review function
  describe 'Add Expert Review' do
    before :each do
      # create instructor
      @student = create(:student)

      @questionnaire = create(:questionnaire)

      # Create an assignment with calibration
      @assignment = create :assignment, is_calibrated: true
      @assignment_questionnaire = create :assignment_questionnaire, assignment: @assignment

      # Create a team linked to the calibrated assignment
      @team = create :assignment_team, assignment: @assignment

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
      login_as @instructor.name

      # should be able to edit assignment to add a expert review
      visit "/review_mapping/add_calibration/#{@assignment.id}?team_id=#{@team.id}"
      # submit expert review
      click_on 'Submit Review'
      page.driver.browser.switch_to.alert.accept
      # expect result
      # If the review was uploaded, there will be a edit link
      expect(page).to have_content('Editing Assignment: final2')
    end

    # Student should not be able to submit an expert review
    it 'student should not be able to add an expert review', js: true do
      # login as student
      login_as @student.name

      # Should not be able to visit expert review page
      visit "/review_mapping/add_calibration/#{@assignment.id}?team_id=#{@team.id}"
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
    # pick a due date for the review
    # TOD0: change this to actually be tomorrow, or put into factory
    page.execute_script("$('#datetimepicker_review_round_1').val('2099/03/20 15:29 (UTC -04:00)')")
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

  # test display calibration
  describe 'Create and Display Calibration' do
    before :each do
      # create instructor
      @student2 = create(:student)
      @student = create(:student)

      @questionnaire_name = 'calibration_questionnaire'
      # Create an assignment with calibration
      # Either course: nil is required or an AssignmentNode must also be created.
      # The page will not load if the assignment has a course but no mapping node.
      @assignment = create :assignment, is_calibrated: true, instructor: @instructor, course: nil

      # Create an assignment due date
      create :assignment_due_date, due_at: (DateTime.now + 1)

      # Create a team linked to the calibrated assignment
      @team = create :assignment_team, assignment: @assignment

      # Create an assignment participant linked to the assignment
      @participant = create :participant, assignment: @assignment, user: @student

      # Create a mapping between the assignment team and the
      # participant object's user (the submitter).
      create :team_user, team: @team, user: @student
      create :review_response_map, assignment: @assignment, reviewee: @team

      # Create a team linked to the calibrated assignment
      @team2 = create :assignment_team, assignment: @assignment

      # Create an assignment participant linked to the assignment
      @participant2 = create :participant, assignment: @assignment, user: @student2

      # Create a mapping between the assignment team and the
      # participant object's user (the submitter).
      create :team_user, team: @team2, user: @student2
      create :review_response_map, assignment: @assignment, reviewee: @team2
    end

    # creates a questionnaire, assigns it to the assignment, fills out the questionaire,
    # displays the questionaire response, checks to make sure the score is there

    # Removing this test since the 'Score' is removed in Pull 678
    # it 'create a questionnaire, fill it out, display results', :js => true do
    #   create_fill_questionnaire
    #   #review should be submitted at this point. click on view to make sure you can see it
    #   #click_link "View"
    #   visit "/response/view?id=#{@assignment.id}&return=assignment_edit"
    #   #review is hidden by default, click on show review to show your review.
    #   click_on "show review"
    #   #once you click show review, the score label comes up as well as some other fields.
    #   expect(page).to have_content('Score:')
    # end
  end

  # test display calibration
  describe 'Display Calibration For Student' do
    before :each do
      # create instructor
      @student2 = create(:student)
      @student = create(:student)

      @questionnaire_name = 'calibration_questionnaire'
      # Create an assignment with calibration
      # Either course: nil is required or an AssignmentNode must also be created.
      # The page will not load if the assignment has a course but no mapping node.
      @assignment = create :assignment, is_calibrated: true, instructor: @instructor, course: nil

      # Create an assignment due date
      create :assignment_due_date, due_at: (DateTime.now + 1)

      @review_deadline_type = create(:deadline_type, name: "review")
      create :assignment_due_date, due_at: (DateTime.now + 1), deadline_type: @review_deadline_type

      # Create a team linked to the calibrated assignment
      @team = create :assignment_team, assignment: @assignment

      # Create an assignment participant linked to the assignment
      @participant = create :participant, assignment: @assignment, user: @student

      # Create a mapping between the assignment team and the
      # participant object's user (the submitter).
      create :team_user, team: @team, user: @student
      create :review_response_map, assignment: @assignment, reviewee: @team

      # Create a team linked to the calibrated assignment
      @team2 = create :assignment_team, assignment: @assignment

      # Create an assignment participant linked to the assignment
      @participant2 = create :participant, assignment: @assignment, user: @student2

      # Create a mapping between the assignment team and the
      # participant object's user (the submitter).
      create :team_user, team: @team2, user: @student2
      create :review_response_map, assignment: @assignment, reviewee: @team2

      # creating the questionnaire and then linking it to the assignment.
      @questionnaire = create :questionnaire
      @assignment_questionnaire = create :assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire
    end

    # creates a questionnaire, assigns it to the assignment, fills out the questionaire,
    # displays the questionaire response, checks to make sure the score is there
    it 'create a questionnaire, fill it out, display results', js: true do
      create_fill_questionnaire

      # REVIEW: should be submitted at this point. click on view to make sure you can see it
      # click_link "View"
      visit "/response/view?id=#{@assignment.id}&return=assignment_edit"
      # REVIEW: is hidden by default, click on show review to show your review.
      click_on "show review"
      # once you click show review, the score label comes up as well as some other fields.
      # Removing this check since this text is removed in Pull 678
      # expect(page).to have_content('Score:')

      # login as student1
      visit "/menu/impersonate"
      fill_in 'user[name]', with: @student.name
      click_button('Impersonate')

      # login_as @student.name
      # go to the assignment page and request a review
      visit "/menu/student_task"
      click_on "final2"

      expect(page).to have_content('')
      click_on "Others' work"
      # the review should now be avaliable, now click on begin.
      click_on "Show calibration results"
      expect(page).to have_content('Expert review')
      expect(page).to have_content('Your review')
    end
  end

  describe 'Reviewer' do
    # Set up for testing
    before :each do
      # Create an instructor and 3 students
      @student = create :student
      @nonreviewer = create :student
      @submitter = create :student

      # Create an assignment with calibration
      # Either course: nil is required or an AssignmentNode must also be created.
      # The page will not load if the assignment has a course but no mapping node.
      @assignment = create :assignment, is_calibrated: true, instructor: @instructor, course: nil

      # Create an assignment due date
      create :assignment_due_date, due_at: (DateTime.now + 1)

      # Create a team linked to the calibrated assignment
      @team = create :assignment_team, assignment: @assignment

      # Create an assignment participant linked to the assignment
      @participant_submitter = create :participant, assignment: @assignment, user: @submitter
      @participant_reviewer = create :participant, assignment: @assignment, user: @nonreviewer
      @participant_reviewer_2 = create :participant, assignment: @assignment, user: @student

      # Create a mapping between the assignment team and the
      # participant object's user.
      create :team_user, team: @team, user: @nonreviewer

      # Create and map a questionnaire (rubric) to the assignment
      @questionnaire = create :questionnaire
      create :question, questionnaire: @questionnaire
      create :assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire
      create :review_response_map, assignment: @assignment, reviewee: @team
    end

    it'instructor should be able to assign artifact to reviewer', js: true do
      # Log in as an instructor
      login_as @instructor.name

      # Edit assignment route
      visit edit_assignment_path @assignment

      click_on('Review strategy')

      # Choose the option for instructor to assign student to review artifacts
      page.select 'Instructor-Selected', from: 'assignment_form_assignment_review_assignment_strategy'

      # Assign reviewer
      click_on('Assign reviewers')

      # Add students to review one artifacts
      click_on('add reviewer')

      # Go to the page where instructor can add student to one artifact
      visit "/review_mapping/select_reviewer?contributor_id=#{@team.id}&id=#{@assignment.id}"

      # Input the student's name for the review
      fill_in 'user_name', with: @student.name

      # Add reviewer
      click_on 'Add Reviewer'

      # Verify the student has been assigned to the artifact
      expect(page).to have_content @student.name
    end

    # Verify submitters can submit artifacts
    it 'can review artifacts', js: true do
      # Log in as student
      login_as @student.name

      # Click on the assignment link, and navigate to work view
      click_link @assignment.name

      # Be able to review others' work
      click_link 'Others\' work'

      # Click_link 'Request a new submission to review'
      find('input[value="Request a new submission to review"]').click

      # Be able to start a review
      expect(page).to have_link 'Begin'
    end
    it 'can not review artifacts if not a assigned a review', js: true do
      # Log in as a student who hasn't been assigned a artifact to review
      login_as @nonreviewer.name

      # Click on the assignment link, and navigate to work view
      click_link @assignment.name

      # Be able to review others' work
      click_link 'Others\' work'

      # Click_link 'Request a new submission to review'
      find('input[value="Request a new submission to review"]').click

      # Do not have any artifacts to review
      expect(page).to have_content("No artifact are available to review at this time. Please try later.")
    end
  end
end
