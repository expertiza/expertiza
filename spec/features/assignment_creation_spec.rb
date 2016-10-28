require 'rails_helper'


def questionnaire_options(assignment, type, _round = 0)
  questionnaires = Questionnaire.where(['private = 0 or instructor_id = ?', assignment.instructor_id]).order('name')
  options = []
  questionnaires.select {|x| x.type == type }.each do |questionnaire|
    options << [questionnaire.name, questionnaire.id]
  end
  options
end

def get_questionnaire(finder_var = nil)
  if finder_var.nil?
    AssignmentQuestionnaire.find_by_assignment_id(@assignment[:id])
  else
    AssignmentQuestionnaire.where(assignment_id: @assignment[:id]).where(questionnaire_id: get_selected_id(finder_var))
  end
end

def get_selected_id(finder_var)
  if finder_var == "ReviewQuestionnaire2"
    ReviewQuestionnaire.find_by_name(finder_var)[:id]
  elsif finder_var == "AuthorFeedbackQuestionnaire2"
    AuthorFeedbackQuestionnaire.find_by_name(finder_var)[:id]
  elsif finder_var == "TeammateReviewQuestionnaire2"
    TeammateReviewQuestionnaire.find_by_name(finder_var)[:id]
  end
end
describe "assignment function" do
  before(:each) do
    #app.default_url_options = { :locale => :es }
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

  describe "creation page", js: true do
    before(:each) do
      (1..3).each do |i|
        create(:course, name: "Course #{i}")
      end
    end

    it "is able to create Review Questionnaire" do
      login_as("instructor6")
      visit "/questionnaires/new?model=ReviewQuestionnaire&private=0"
      fill_in 'questionnaire_name', with: 'new public review questionnaire'
      fill_in 'questionnaire_min_question_score', with: '0'
      fill_in 'questionnaire_max_question_score', with: '5'
      expect(page).to have_select("questionnaire[private]", options: ['no', 'yes'])
      click_button 'Create'
      questionnaire = Questionnaire.where(name: 'new public review questionnaire').first
      expect(questionnaire).to have_attributes(
        name: 'new public review questionnaire',
        max_question_score: 5,
        min_question_score: 0)
    end
    # Might as well test small flags for creation here
    it "is able to create a public assignment" do
      login_as("instructor6")
      visit "/assignments/new?private=0"

      fill_in 'assignment_form_assignment_name', with: 'public assignment for test'
      select('Course 2', from: 'assignment_form_assignment_course_id')
      fill_in 'assignment_form_assignment_directory_path', with: 'testDirectory'
      fill_in 'assignment_form_assignment_spec_location', with: 'testLocation'
      check("assignment_form_assignment_microtask")
      check("assignment_form_assignment_reviews_visible_to_all")
      check("assignment_form_assignment_is_calibrated")
      uncheck("assignment_form_assignment_availability_flag")
      expect(page).to have_select("assignment_form[assignment][reputation_algorithm]", options: ['--', 'Hamer', 'Lauw'])

      click_button 'Create'
      assignment = Assignment.where(name: 'public assignment for test').first
      expect(assignment).to have_attributes(
        name: 'public assignment for test',
        course_id: Course.find_by_name('Course 2')[:id],
        directory_path: 'testDirectory',
        spec_location: 'testLocation',
        microtask: true,
        is_calibrated: true,
        availability_flag: false
      )
    end

    it "is able to create a private assignment" do
      login_as("instructor6")
      visit "/assignments/new?private=1"

      fill_in 'assignment_form_assignment_name', with: 'private assignment for test'
      select('Course 2', from: 'assignment_form_assignment_course_id')
      fill_in 'assignment_form_assignment_directory_path', with: 'testDirectory'
      fill_in 'assignment_form_assignment_spec_location', with: 'testLocation'
      check("assignment_form_assignment_microtask")
      check("assignment_form_assignment_reviews_visible_to_all")
      check("assignment_form_assignment_is_calibrated")
      uncheck("assignment_form_assignment_availability_flag")
      expect(page).to have_select("assignment_form[assignment][reputation_algorithm]", options: ['--', 'Hamer', 'Lauw'])

      click_button 'Create'
      assignment = Assignment.where(name: 'private assignment for test').first
      expect(assignment).to have_attributes(
        name: 'private assignment for test',
        course_id: Course.find_by_name('Course 2')[:id],
        directory_path: 'testDirectory',
        spec_location: 'testLocation'
      )
    end

    it "is able to create with teams" do
      login_as("instructor6")
      visit '/assignments/new?private=1'

      fill_in 'assignment_form_assignment_name', with: 'private assignment for test'
      select('Course 2', from: 'assignment_form_assignment_course_id')
      fill_in 'assignment_form_assignment_directory_path', with: 'testDirectory'
      check("team_assignment")
      check("assignment_form_assignment_show_teammate_reviews")
      fill_in 'assignment_form_assignment_max_team_size', with: 3

      click_button 'Create'

      assignment = Assignment.where(name: 'private assignment for test').first
      expect(assignment).to have_attributes(
        max_team_size: 3,
        show_teammate_reviews: true
      )
    end

    it "is able to create with quiz" do
      login_as("instructor6")
      visit '/assignments/new?private=1'

      fill_in 'assignment_form_assignment_name', with: 'private assignment for test'
      select('Course 2', from: 'assignment_form_assignment_course_id')
      fill_in 'assignment_form_assignment_directory_path', with: 'testDirectory'
      check("assignment_form_assignment_require_quiz")
      click_button 'Create'
      fill_in 'assignment_form_assignment_num_quiz_questions', with: 3
      click_button 'submit_btn'

      assignment = Assignment.where(name: 'private assignment for test').first
      expect(assignment).to have_attributes(
        num_quiz_questions: 3,
        require_quiz: true
      )
    end

    it "is able to create with staggered deadline" do
      skip('skip test on staggered deadline temporarily')
      login_as("instructor6")
      visit '/assignments/new?private=1'

      fill_in 'assignment_form_assignment_name', with: 'private assignment for test'
      select('Course 2', from: 'assignment_form_assignment_course_id')
      fill_in 'assignment_form_assignment_directory_path', with: 'testDirectory'
      begin
        check("assignment_form_assignment_staggered_deadline")
      rescue
        return
      end
      page.driver.browser.switch_to.alert.accept
      click_button 'Create'
      fill_in 'assignment_form_assignment_days_between_submissions', with: 7
      click_button 'submit_btn'

      assignment = Assignment.where(name: 'private assignment for test').first
      pending(%(not sure what's broken here but the error is: #ActionController::RoutingError: No route matches [GET] "/assets/staggered_deadline_assignment_graph/graph_1.jpg"))
      expect(assignment).to have_attributes(
        staggered_deadline: true
      )
    end

    ## should be able to create with review visible to all reviewres
    it "is able to create with review visible to all reviewers" do
      login_as("instructor6")
      visit '/assignments/new?private=1'
      fill_in 'assignment_form_assignment_name', with: 'private assignment for test'
      select('Course 2', from: 'assignment_form_assignment_course_id')
      fill_in 'assignment_form_assignment_directory_path', with: 'testDirectory'
      fill_in 'assignment_form_assignment_spec_location', with: 'testLocation'
      check('assignment_form_assignment_reviews_visible_to_all')
      click_button 'Create'
      expect(page).to have_select("assignment_form[assignment][reputation_algorithm]", options: ['--', 'Hamer', 'Lauw'])
      #click_button 'Create'
      assignment = Assignment.where(name: 'private assignment for test').first
      expect(assignment).to have_attributes(
                                name: 'private assignment for test',
                                course_id: Course.find_by_name('Course 2')[:id],
                                directory_path: 'testDirectory',
                                spec_location: 'testLocation')
    end

    it "is able to create public micro-task assignment" do
      login_as("instructor6")
      visit '/assignments/new?private=0'

      fill_in 'assignment_form_assignment_name', with: 'public assignment for test'
      select('Course 2', from: 'assignment_form_assignment_course_id')
      fill_in 'assignment_form_assignment_directory_path', with: 'testDirectory'
      check('assignment_form_assignment_microtask')
      click_button 'Create'

      assignment = Assignment.where(name: 'public assignment for test').first
      expect(assignment).to have_attributes(
                                microtask: true)
    end
    it "is able to create calibrated public assignment" do
      login_as("instructor6")
      visit '/assignments/new?private=0'

      fill_in 'assignment_form_assignment_name', with: 'public assignment for test'
      select('Course 2', from: 'assignment_form_assignment_course_id')
      fill_in 'assignment_form_assignment_directory_path', with: 'testDirectory'
      check("assignment_form_assignment_is_calibrated")
      click_button 'Create'

      assignment = Assignment.where(name: 'public assignment for test').first
      expect(assignment).to have_attributes(
                                is_calibrated: true)
    end
  end
  ## adding test for general tab
  describe "general tab", js: true do
    before(:each) do
      (1..3).each do |i|
        create(:course, name: "Course #{i}")
      end
      create(:assignment, name: 'edit assignment for test')

      assignment = Assignment.where(name: 'edit assignment for test').first
      login_as("instructor6")
      visit "/assignments/#{assignment[:id]}/edit"
      click_link 'General'
    end

    it "should edit assignment available to students" do
      fill_in 'assignment_form_assignment_name', with: 'edit assignment for test'
      select('Course 2', from: 'assignment_form_assignment_course_id')
      fill_in 'assignment_form_assignment_directory_path', with: 'testDirectory1'
      fill_in 'assignment_form_assignment_spec_location', with: 'testLocation1'
      check("assignment_form_assignment_microtask")
      check("assignment_form_assignment_is_calibrated")
      click_button 'Save'
      assignment = Assignment.where(name: 'edit assignment for test').first
      expect(assignment).to have_attributes(
                                name: 'edit assignment for test',
                                course_id: Course.find_by_name('Course 2')[:id],
                                directory_path: 'testDirectory1',
                                spec_location: 'testLocation1',
                                microtask: true,
                                is_calibrated: true,
                            )
    end

    it "should edit quiz number available to students" do
      fill_in 'assignment_form_assignment_name', with: 'edit assignment for test'
      select('Course 2', from: 'assignment_form_assignment_course_id')
      fill_in 'assignment_form_assignment_directory_path', with: 'testDirectory1'
      fill_in 'assignment_form_assignment_spec_location', with: 'testLocation1'
      check("assignment_form_assignment_require_quiz")
      click_button 'Save'
      fill_in 'assignment_form_assignment_num_quiz_questions', with: 5
      click_button 'Save'
      assignment = Assignment.where(name: 'edit assignment for test').first
      expect(assignment).to have_attributes(
                                name: 'edit assignment for test',
                                course_id: Course.find_by_name('Course 2')[:id],
                                directory_path: 'testDirectory1',
                                spec_location: 'testLocation1',
                                num_quiz_questions: 5,
                                require_quiz: true
                            )

    end

    it "should edit number of members per team " do
      fill_in 'assignment_form_assignment_name', with: 'edit assignment for test'
      select('Course 2', from: 'assignment_form_assignment_course_id')
      fill_in 'assignment_form_assignment_directory_path', with: 'testDirectory1'
      fill_in 'assignment_form_assignment_spec_location', with: 'testLocation1'
      check("assignment_form_assignment_show_teammate_reviews")
      fill_in 'assignment_form_assignment_max_team_size', with: 5
      click_button 'Save'
      assignment = Assignment.where(name: 'edit assignment for test').first
      expect(assignment).to have_attributes(
                                name: 'edit assignment for test',
                                course_id: Course.find_by_name('Course 2')[:id],
                                directory_path: 'testDirectory1',
                                spec_location: 'testLocation1',
                                max_team_size: 5,
                                show_teammate_reviews: true
                            )
    end

    ##### test reviews visible to all other reviewers ######
    it "should edit review visible to all other reviewers" do
      fill_in 'assignment_form_assignment_name', with: 'edit assignment for test'
      select('Course 2', from: 'assignment_form_assignment_course_id')
      fill_in 'assignment_form_assignment_directory_path', with: 'testDirectory1'
      fill_in 'assignment_form_assignment_spec_location', with: 'testLocation1'
      check ("assignment_form_assignment_reviews_visible_to_all")
      click_button 'Save'
      assignment = Assignment.where(name: 'edit assignment for test').first
      expect(assignment).to have_attributes(
                                name: 'edit assignment for test',
                                course_id: Course.find_by_name('Course 2')[:id],
                                directory_path: 'testDirectory1',
                                spec_location: 'testLocation1'
                            )
    end
  end

  describe "topics tab", js: true do
    before(:each) do
      (1..3).each do |i|
        create(:course, name: "Course #{i}")
      end
      create(:assignment, name: 'public assignment for test')

      @assignment = Assignment.where(name: 'public assignment for test').first
      login_as("instructor6")
      visit "/assignments/#{@assignment[:id]}/edit"
      click_link 'Topics'
    end

    it "can edit topics properties" do
      check("assignment_form_assignment_allow_suggestions")
      check("assignment_form_assignment_is_intelligent")
      check("assignment_form_assignment_can_review_same_topic")
      check("assignment_form_assignment_can_choose_topic_to_review")
      check("assignment_form_assignment_use_bookmark")
      click_button 'submit_btn'
      assignment = Assignment.where(name: 'public assignment for test').first
      expect(assignment).to have_attributes(
        allow_suggestions: true,
        is_intelligent: true,
        can_review_same_topic: true,
        can_choose_topic_to_review: true,
        use_bookmark: true
      )
    end

    it "can edit topics properties" do
      uncheck("assignment_form_assignment_allow_suggestions")
      uncheck("assignment_form_assignment_is_intelligent")
      uncheck("assignment_form_assignment_can_review_same_topic")
      uncheck("assignment_form_assignment_can_choose_topic_to_review")
      uncheck("assignment_form_assignment_use_bookmark")
      click_button 'submit_btn'
      assignment = Assignment.where(name: 'public assignment for test').first
      expect(assignment).to have_attributes(
        allow_suggestions: false,
        is_intelligent: false,
        can_review_same_topic: false,
        can_choose_topic_to_review: false,
        use_bookmark: false
      )
    end

    it "Add new topic" do
      click_link 'New topic'
      click_button 'OK'
      fill_in 'topic_topic_identifier', with: '1'
      fill_in 'topic_topic_name', with: 'Test'
      fill_in 'topic_category', with: 'Test Category'
      fill_in 'topic_max_choosers', with: 2
      click_button 'Create'

      sign_up_topics = SignUpTopic.where(topic_name: 'Test').first
      expect(sign_up_topics).to have_attributes(
        topic_name: 'Test',
        assignment_id: 1,
        max_choosers: 2,
        topic_identifier: '1',
        category: 'Test Category'
      )
    end

    it "Delete existing topic" do
      create(:sign_up_topic, assignment_id: @assignment[:id])
      visit "/assignments/#{@assignment[:id]}/edit"
      click_link 'Topics'
      all(:xpath, '//img[@title="Delete Topic"]')[0].click
      click_button 'OK'

      topics_exist = SignUpTopic.count(:all, assignment_id: @assignment[:id])
      expect(topics_exist).to be_eql 0
    end

  end

  # Begin rubric tab
  describe "rubrics tab", js: true do
    before(:each) do
      @assignment = create(:assignment)
      create_list(:participant, 3)
      # Create an assignment due date
      create :assignment_due_date, due_at: (DateTime.now - 1)
      @review_deadline_type = create(:deadline_type, name: "review")
      create :assignment_due_date, due_at: (DateTime.now + 1), deadline_type: @review_deadline_type
      create(:assignment_node)
      create(:question)
      create(:questionnaire)
      create(:assignment_questionnaire)
      (1..3).each do |i|
        create(:questionnaire, name: "ReviewQuestionnaire#{i}")
        create(:author_feedback_questionnaire, name: "AuthorFeedbackQuestionnaire#{i}")
        create(:teammate_review_questionnaire, name: "TeammateReviewQuestionnaire#{i}")
      end
      login_as("instructor6")
      visit "/assignments/#{@assignment.id}/edit"
      click_link 'Rubrics'
    end

    describe "Load rubric questionnaire" do
      it "is able to edit assignment" do
        #find_link('Rubrics').click
        # might find a better acceptance criteria here
        expect(page).to have_content("Review rubric varies by round")
      end
    end

    # First row of rubric
    describe "Edit review rubric" do
      it "updates review questionnaire" do
        #find_link('Rubrics').click
        #within_table('question_actions_table') do
          within(:css, "tr#questionnaire_table_ReviewQuestionnaire") do
          select "ReviewQuestionnaire2", from: 'assignment_form[assignment_questionnaire][][questionnaire_id]'
          uncheck('dropdown')
          select "Scale", from: 'assignment_form[assignment_questionnaire][][dropdown]'
          fill_in 'assignment_form[assignment_questionnaire][][questionnaire_weight]', with: '50'
          fill_in 'assignment_form[assignment_questionnaire][][notification_limit]', with: '50'
        end
        click_button 'Save'
        sleep 1
        questionnaire = get_questionnaire("ReviewQuestionnaire2").first
        expect(questionnaire).to have_attributes(
          questionnaire_weight: 50,
          notification_limit: 50
        )
      end

      it "should update scored question dropdown" do
        #find_link('Rubrics').click
        #within_table('question_actions_table') do
        within("tr#questionnaire_table_ReviewQuestionnaire") do
          select "ReviewQuestionnaire2", from: 'assignment_form[assignment_questionnaire][][questionnaire_id]'
          select "Scale", from: 'assignment_form[assignment_questionnaire][][dropdown]'
        end
        click_button 'Save'
        questionnaire = Questionnaire.where(name: "ReviewQuestionnaire2").first
        assignment_questionnaire = AssignmentQuestionnaire.where(assignment_id: @assignment.id, questionnaire_id: questionnaire.id).first
        expect(assignment_questionnaire.dropdown).to eq(false)
      end

      # Second row of rubric
      it "updates author feedback questionnaire" do
       # find_link('Rubrics').click
       #within_table('assignment_questionnaire_table') do
        within(:css, "tr#questionnaire_table_AuthorFeedbackQuestionnaire") do
          select "AuthorFeedbackQuestionnaire2", from: 'assignment_form[assignment_questionnaire][][questionnaire_id]'
          uncheck('dropdown')
          select "Scale", from: 'assignment_form[assignment_questionnaire][][dropdown]'
          fill_in 'assignment_form[assignment_questionnaire][][questionnaire_weight]', with: '50'
          fill_in 'assignment_form[assignment_questionnaire][][notification_limit]', with: '50'
        end
        click_button 'Save'
        questionnaire = get_questionnaire("AuthorFeedbackQuestionnaire2").first
        expect(questionnaire).to have_attributes(
          questionnaire_weight: 50,
          notification_limit: 50
        )
      end

      it "should update scored question dropdown" do
        #find_link('Rubrics').click
        #within_table('question_actions_table') do
        within("tr#questionnaire_table_AuthorFeedbackQuestionnaire") do
          select "AuthorFeedbackQuestionnaire2", from: 'assignment_form[assignment_questionnaire][][questionnaire_id]'
          select "Scale", from: 'assignment_form[assignment_questionnaire][][dropdown]'
        end
        click_button 'Save'
        questionnaire = Questionnaire.where(name: "AuthorFeedbackQuestionnaire2").first
        assignment_questionnaire = AssignmentQuestionnaire.where(assignment_id: @assignment.id, questionnaire_id: questionnaire.id).first
        expect(assignment_questionnaire.dropdown).to eq(false)
      end


      ##
      # Third row of rubric
      xit "updates teammate review questionnaire" do
        #find_link('Rubrics').click
        #within_table('question_actions_table') do
        within("tr#questionnaire_table_TeammateReviewQuestionnaire") do
          select "TeammateReviewQuestionnaire2", from: 'assignment_form[assignment_questionnaire][][questionnaire_id]'
          uncheck('dropdown')
          select "Scale", from: 'assignment_form[assignment_questionnaire][][dropdown]'
          fill_in 'assignment_form[assignment_questionnaire][][questionnaire_weight]', with: '50'
          fill_in 'assignment_form[assignment_questionnaire][][notification_limit]', with: '50'
        end
        click_button 'Save'
        questionnaire = get_questionnaire("TeammateReviewQuestionnaire2").first
        expect(questionnaire).to have_attributes(
          questionnaire_weight: 50,
          notification_limit: 50
        )
      end

      xit "should update scored question dropdown" do
        #find_link('Rubrics').click
        #within_table('question_actions_table') do
        within("tr#questionnaire_table_TeammateReviewQuestionnaire") do
          select "TeammateReviewQuestionnaire2", from: 'assignment_form[assignment_questionnaire][][questionnaire_id]'
          select "Scale", from: 'assignment_form[assignment_questionnaire][][dropdown]'
        end
        click_button 'Save'
        questionnaire = Questionnaire.where(name: "TeammateReviewQuestionnaire2").first
        assignment_questionnaire = AssignmentQuestionnaire.where(assignment_id: @assignment.id, questionnaire_id: questionnaire.id).first
        expect(assignment_questionnaire.dropdown).to eq(false)
      end
    end
  end

  #Begin review strategy tab
  describe "review strategy tab", js: true do
    before(:each) do
      create(:assignment, name: 'public assignment for test')
      @assignment_id = Assignment.where(name: 'public assignment for test').first.id
    end

    it "auto selects" do
      login_as("instructor6")
      visit "/assignments/#{@assignment_id}/edit"
      find_link('ReviewStrategy').click
      select "Auto-Selected", from: 'assignment_form_assignment_review_assignment_strategy'
      fill_in 'assignment_form_assignment_review_topic_threshold', with: 3
      fill_in 'assignment_form_assignment_max_reviews_per_submission', with: 10
      click_button 'Save'
      assignment = Assignment.where(name: 'public assignment for test').first
      expect(assignment).to have_attributes(
        review_assignment_strategy: 'Auto-Selected',
        review_topic_threshold: 3,
        max_reviews_per_submission: 10
      )
    end

    # instructor assign reviews will happen only one time, so the data will not be store in DB.
    xit "sets number of reviews by each student" do
      pending('review section not yet completed')
      login_as("instructor6")
      visit '/assignments/1/edit'
      find_link('ReviewStrategy').click
      select "Instructor-Selected", from: 'assignment_form_assignment_review_assignment_strategy'
      check 'num_reviews_student'
      fill_in 'num_reviews_per_student', with: 5
    end
  end
  end


