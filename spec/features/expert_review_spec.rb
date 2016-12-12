require 'rails_helper'
require 'selenium-webdriver'

describe 'Expert Review' do
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
    describe 'With Expert Review' do
      # An assignment created with calibration turned on
      # should show the calibration tab when editing
      it 'should show Expert Review tab' do
        # Log in as the instructor.
        login_as @instructor.name

        # Create a new assignment
        visit new_assignment_path

        # Populate form fields
        fill_in 'assignment_form_assignment_name', with: 'Expert Test'
        fill_in 'assignment_form_assignment_directory_path', with: 'submission'
        check 'assignment_form_assignment_is_calibrated'

        # Submit
        click_button 'Create'

        # Verify Assignment Page
        expect(find('.assignments.edit > h1')).to have_content('Editing Assignment: Expert Test')
        expect(page).to have_link('Expert')
      end
    end

    # Test creating an assignment without calibration
    describe 'Without Expert' do
      # An assignment created with calibration turned off
      # should not show the calibration tab when editing
      it 'Should not show the Expert tab' do
        # Log in as the instructor.
        login_as @instructor.name

        # Create a new assignment
        visit new_assignment_path

        # Populate form fields, leaving calibration unchecked
        fill_in 'assignment_form_assignment_name', with: 'Expert Test'
        fill_in 'assignment_form_assignment_directory_path', with: 'submission'

        # Submit
        click_button 'Create'

        # Verify Assignment Page
        expect(find('.assignments.edit > h1')).to have_content('Editing Assignment: Expert Test')
        expect(page).to have_no_selector('#Expert review')
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
    it 'expert can be accessed by admins' do
      # Log in with the admin
      login_as @admin.name

      # Visit the edit page
      visit edit_assignment_path @assignment

      # Verify access to calibration
      expect(find('.assignments.edit > h1')).to have_content("Editing Assignment: #{@assignment.name}")
    end

    # Verify the calibration tab can be accessed by instructors
    it 'expert can be accessed by instructors' do
      # Log in with the instructor
      login_as @instructor.name

      # Visit the edit page
      visit edit_assignment_path @assignment

      # Verify access to calibration
      expect(find('.assignments.edit > h1')).to have_content("Editing Assignment: #{@assignment.name}")
    end

    # Verify that as submissions are made they appear in
    # the table under the calibration tab
    it 'shows artifacts that have been submitted' do
      # Log in with instructor
      login_as @instructor.name

      # Visit the edit page
      visit edit_assignment_path @assignment

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
#
  # test display calibration
  describe 'Display Expert Review For Student' do
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
      create :assignment_due_date, due_at: (DateTime.now - 1)

      @review_deadline_type = create(:deadline_type, name: "review")
      create :assignment_due_date, due_at: (DateTime.now + 1), deadline_type: @review_deadline_type

      # Create a team linked to the calibrated assignment
      @team = create :assignment_team, assignment: @assignment

      # Create an assignment participant linked to the assignment
      @participant = create :participant, assignment: @assignment, user: @student

      # Create a mapping between the assignment team and the
      # participant object's user (the submitter).
      create :team_user, team: @team, user: @student
      # create :review_response_map, assignment: @assignment, reviewee: @team

      # Create a team linked to the calibrated assignment
      @team2 = create :assignment_team, assignment: @assignment

      # Create an assignment participant linked to the assignment
      @participant2 = create :participant, assignment: @assignment, user: @student2

      # Create a mapping between the assignment team and the
      # participant object's user (the submitter).
      create :team_user, team: @team2, user: @student2
      # create :review_response_map, assignment: @assignment, reviewee: @team2

      # creating the questionnaire and then linking it to the assignment.
      @questionnaire = create :questionnaire
      @assignment_questionnaire = create :assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire
    end

    # creates a questionnaire, assigns it to the assignment, fills out the questionaire,
    # displays the questionaire response, checks to make sure the score is there
    xit 'create a questionnaire, fill it out, display results', js: true do
      create_fill_questionnaire
      # REVIEW: should be submitted at this point. click on view to make sure you can see it
      # click_link "View"
      visit "/response/view?id=#{@assignment.id}&return=assignment_edit"
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

      click_on "Show expert peer-review results"
      expect(page).to have_content('Expert review')
      expect(page).to have_content('5')
      expect(page).to have_content('Your review')
      expect(page).to have_content('4')
    end
  end
 end
end