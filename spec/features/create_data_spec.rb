require 'rails_helper'
xdescribe "create data" do
  it "create data" do

    create(:deadline_type, name: "submission")
    create(:deadline_type, name: "review")
    create(:deadline_type, name: "metareview")
    create(:deadline_type, name: "drop_topic")
    create(:deadline_type, name: "signup")
    create(:deadline_type, name: "team_formation")
    create(:deadline_right)
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')


    #create airbrake test data
    @assignment=create(:assignment, name: "TestAssignment_airbrake", directory_path: 'test_assignment')
    create_list(:participant, 3,assignment: Assignment.find_by(name:'TestAssignment_airbrake'))
    create(:assignment_node,node_object_id:@assignment.id)
    create(:assignment_due_date, assignment:@assignment,due_at: (DateTime.now.in_time_zone + 10.year))
    create(:assignment_due_date, assignment:@assignment,deadline_type: DeadlineType.where(name: 'review').first, due_at: (DateTime.now.in_time_zone + 100.year))
    @topic1=create(:topic, assignment: @assignment,topic_name: "TestReview_airbrake")
    @topic2=create(:topic, assignment: @assignment,topic_name: "TestReview_airbrake2")
    @team1=create(:assignment_team,name:'airbrake_test_team1',assignment:@assignment)
    create(:assignment_team,name:'airbrake_test_team2',assignment:@assignment)
    create(:signed_up_team,team_id:@team1.id,topic:@topic1)
    create(:team_user, user: User.where(role_id: 2).first,team: AssignmentTeam.find_by(name:'airbrake_test_team1'))
    create(:team_user, user: User.where(role_id: 2).second,team: AssignmentTeam.find_by(name:'airbrake_test_team1'))
    create(:team_user, user: User.where(role_id: 2).third, team: AssignmentTeam.find_by(name:'airbrake_test_team2'))
    create(:signed_up_team, team_id: AssignmentTeam.where(name:'airbrake_test_team1').first.id, topic: SignUpTopic.where(topic_name:'TestReview_airbrake').first)

    create(:assignment_questionnaire,assignment:Assignment.find_by(name:'TestAssignment_airbrake'))
    create(:signed_up_team, team_id: AssignmentTeam.where(name:'airbrake_test_team2').first.id, topic: SignUpTopic.where(topic_name:'TestReview_airbrake2').first)
    (1..25).each { |i| create(:student, name: "student#{i}") }


    #assignment creation test data
    @course=create(:course, name: "assignment_test_Course")
    @assignment1=create(:assignment, name: "assignment_creation_test",course:nil)
    create(:assignment_node,node_object_id:@assignment1.id)
    create :assignment_due_date, assignment:@assignment1,due_at: (DateTime.now - 1)
    create :assignment_due_date, assignment:@assignment1,due_at: (DateTime.now + 100.year), deadline_type: DeadlineType.where(name: 'review').first

    @assignment2=create(:assignment, name: 'participants Assignment',course:@course)
    create(:assignment_node,node_object_id:@assignment2.id)
    create :assignment_due_date, assignment:@assignment2,due_at: (DateTime.now - 1)
    create :assignment_due_date, assignment:@assignment2,due_at: (DateTime.now + 100.year), deadline_type: DeadlineType.where(name: 'review').first

    @assignment3=create(:assignment, name: 'edit assignment for test',course:@course)
    create(:assignment_node,node_object_id:@assignment3.id)

    @assignment4=create(:assignment, name: "Rubric_tab_test")
    create :assignment_due_date, assignment:@assignment4,due_at: (DateTime.now - 1)
    create :assignment_due_date, assignment:@assignment4,due_at: (DateTime.now + 100.year), deadline_type: DeadlineType.where(name: 'review').first
    create(:assignment_node,node_object_id:@assignment4.id)
    create(:questionnaire)
    create(:question)
    create(:assignment_questionnaire,assignment:@assignment4)
    (1..3).each do |i|
      create(:questionnaire, name: "ReviewQuestionnaire#{i}")
      create(:author_feedback_questionnaire, name: "AuthorFeedbackQuestionnaire#{i}")
      create(:teammate_review_questionnaire, name: "TeammateReviewQuestionnaire#{i}")
    end

    #create review mapping test data
    @assignment = create(:assignment, name: "automatic review mapping test", max_team_size: 4)
    create(:assignment_node,node_object_id:@assignment.id)

    (1..10).each do |i|
       student = User.find_by( name: 'student' + i.to_s)
      #student = create :student, name: 'student' + i.to_s
      participant = create :participant, assignment: @assignment, user: student
      if i % 3 == 1 and i != 10
        instance_variable_set('@team' + (i / 3 + 1).to_s, create(:assignment_team, assignment:@assignment,name: 'review_mapping_team' + i.to_s))
        @team = instance_variable_get('@team' + (i / 3 + 1).to_s)
      end
      create :team_user, user: student, team: @team
    end
#calibration test data!===============================================================================================================================
          # Create an instructor and 3 students
          @student = create :student,name: 'Cali_Reviewer_student'
          @nonreviewer = create :student,name:'Cali_Reviewer_nonstudent'
          @submitter = create :student,name: 'Cali_Review_submitter'

          # Create an assignment with calibration
          # Either course: nil is required or an AssignmentNode must also be created.
          # The page will not load if the assignment has a course but no mapping node.
          @assignment = create :assignment,name: 'Cali_Reviewer_ass', is_calibrated: true, instructor: User.find_by(name:'instructor6'), course: nil

          # Create an assignment due date
          create :assignment_due_date, due_at: (DateTime.now - 1)  ,assignment:@assignment
          @review_deadline_type = DeadlineType.find_by(name: "review")
          create :assignment_due_date, due_at: (DateTime.now + 100), deadline_type: @review_deadline_type,assignment:@assignment
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

        # Create an instructor and student
        begin
          @student = create :student, name: 'student_calibration'
          @submitter1 = create :student,name: 'student_cali_sub1'

          # Create an assignment with calibration
          # Either course: nil is required or an AssignmentNode must also be created.
          # The page will not load if the assignment has a course but no mapping node.
          @assignment = create :assignment,name: 'Calibration_Submit_Test2', is_calibrated: true, instructor: User.find_by(name:'instructor6'), course: nil

          # Create an assignment due date
          create :assignment_due_date, due_at: (DateTime.now + 100), assignment:Assignment.find_by(name: 'Calibration_Submit_Test2')

          # Create a team linked to the calibrated assignment
          @team = create :assignment_team,name: 'Edit_Assignment_Calibration_team2', assignment: Assignment.find_by(name: 'Calibration_Submit_Test2')

          # Create an assignment participant linked to the assignment
          @participant = create :participant, assignment: Assignment.find_by(name: 'Calibration_Submit_Test2'), user: @submitter1

          # Create a mapping between the assignment team and the
          # participant object's user (the submitter).
          create :team_user, team: Team.find_by(name:'Edit_Assignment_Calibration_team2' ), user: @submitter
        end
        begin

          # Create an instructor and admin
          @admin = create(:admin)

          # Create an assignment with calibration
          @assignment = create :assignment,name: 'Edit_Assignment_Calibration', is_calibrated: true

          # Create a team linked to the calibrated assignment
          @team = create :assignment_team, name:'Edit_Assignment_Calibration_team1',assignment:Assignment.find_by(name:'Edit_Assignment_Calibration')

          # Create an assignment participant linked to the assignment.
          # The factory for this implicitly loads or creates a student
          # (user) object that the participant is linked to.
          @submitter = create :participant, assignment:Assignment.find_by(name:'Edit_Assignment_Calibration'), user:User.find_by(name:'student2066')

          # Create a mapping between the assignment team and the
          # participant object's user (the student).
          create :team_user, team: Team.find_by(name:'Edit_Assignment_Calibration_team1' ), user: @submitter.user
        end

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
        @submitter = create :participant, assignment: @assignment,user:@student
        # Create a mapping between the assignment team and the
        # participant object's user (the student).
        create :team_user, team: @team, user: @submitter.user
        create :review_response_map, assignment: @assignment, reviewee: @team
        # create :assignment_questionnaire, assignment: @assignment

    #inherit team data===============================================================

    @inherit_n1 =create(:assignment, name:"inherit_team")
    create(:assignment_node, node_object_id:@inherit_n1.id)
    create(:assignment_team,name:'inherit_team1',assignment:Assignment.find_by(name:'inherit_team'))

    create(:course,name:"inherit_course")
    @inherit_n2 = Course.where(name:'inherit_course').first
    create(:course_node,node_object_id: @inherit_n2.id)
    create(:course_team,name:"inherit_course_team")

    assignment = create(:assignment, name:"inherit_not_display_team")
    @inherit_n3 = Assignment.where(name:'inherit_not_display_team').first
    create(:assignment_node,node_object_id:@inherit_n3.id)
    assignment.update_attributes(course_id: nil)

    #list teams=============================================================================================
    create(:assignment,name:"List_team")
    @list1=Assignment.find_by(name: 'List_team')
    create(:assignment_node,node_object_id: @list1.id)
    @team=assignment_team = create(:assignment_team,name:'List_team1',assignment:Assignment.find_by(name:'List_team'))
    team_user = create(:team_user,user:User.where(role_id: 2).first,team:@team)

    #topic suggestion=======================================================================================

    @assignment=create(:assignment, name: "Assignment_suggest_topic", allow_suggestions: true)
    (4..6). each {|i|create(:participant, assignment: Assignment.find_by(name:'Assignment_suggest_topic'),user:User.find_by(name:'student206'+i.to_s))}
    @topic_as = Assignment.find_by(name: 'Assignment_suggest_topic')
    create(:assignment_node,node_object_id: @topic_as.id)
    create :assignment_due_date, due_at: (DateTime.now + 100),assignment:@assignment
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'review').first, due_at: (DateTime.now + 100),assignment:@assignment)

    #instructor interface==================================================================================

    assignment=create(:assignment, name: "instructor_interface", directory_path: 'test_assignment')
    (4..6). each {|i|create(:participant, assignment: Assignment.find_by(name:'instructor_interface'),user:User.find_by(name:'student206'+i.to_s))}
    create(:assignment_due_date,due_at: (DateTime.now + 100),assignment:@assignment)
    create(:assignment_due_date, assignment:@assignment,deadline_type: DeadlineType.where(name: 'review').first, due_at: Time.now + (100 * 24 * 60 * 60))

    #staggered deadline test==============================================================================
    @assignment=create(:assignment, name: "Assignment1665", directory_path: "Assignment1665", rounds_of_reviews: 2, staggered_deadline: true)
    (4..6). each {|i|create(:participant, assignment: @assignment,user:User.find_by(name:'student206'+i.to_s))}
    @topic1=create(:topic, topic_name: "Topic_1",assignment:@assignment)
    @topic2=create(:topic, topic_name: "Topic_2",assignment:@assignment)
    @team1=create(:assignment_team,name:'staggered_team1',assignment:@assignment)
    @team2=create(:assignment_team,name:'staggered_team2',assignment:@assignment)
    create(:signed_up_team,team_id:@team1.id,topic:@topic1)
    create(:signed_up_team,team_id:@team2.id,topic:@topic2)
    create(:team_user, user: User.where(name:'student2064').first,team: @team1)
    create(:team_user, user: User.where(name:'student2065').first,team: @team2)
    #rubric
    create(:questionnaire, name: "TestQuestionnaire1")
    create(:questionnaire, name: "TestQuestionnaire2")
    create(:question, txt: "Question1", questionnaire: ReviewQuestionnaire.where(name: 'TestQuestionnaire1').first, type: "Criterion")
    create(:question, txt: "Question2", questionnaire: ReviewQuestionnaire.where(name: 'TestQuestionnaire2').first, type: "Criterion")
    create(:assignment_questionnaire, assignment:@assignment,questionnaire: ReviewQuestionnaire.where(name: 'TestQuestionnaire1').first, used_in_round: 1)
    create(:assignment_questionnaire, assignment:@assignment,questionnaire: ReviewQuestionnaire.where(name: 'TestQuestionnaire2').first, used_in_round: 2)

    #assignment deadline
    assignment_due('submission',DateTime.now + 1000,1,1)
    assignment_due('review',    DateTime.now + 2000,1)
    assignment_due('submission',DateTime.now + 3000,2)
    assignment_due('review',    DateTime.now + 4000,2)

    #topic deadline
    topic_due('submission',DateTime.now + 1000,@topic1.id,1,1)
    topic_due('review',    DateTime.now + 2000,@topic1.id,1)
    topic_due('submission',DateTime.now + 3000,@topic1.id,2,1)
    topic_due('review',    DateTime.now + 4000,@topic1.id,2)
    topic_due('submission',DateTime.now + 1000,@topic2.id,1,1)
    topic_due('review',    DateTime.now + 2000,@topic2.id,1)
    topic_due('submission',DateTime.now + 3000,@topic2.id,2,1)
    topic_due('review',    DateTime.now + 4000,@topic2.id,2)

    #questionnaire======================================================
    #quiz===============================================================part1
    # Create an assignment with quiz
    # Setup Student 1

    # Create student
    @student1 = User.find_by(name:'student4')
    @student2 = User.find_by(name:'student5')
    (1..3).each do |i|
        @assignment = create :assignment, name:'quiz_test_assignment'+i.to_s,require_quiz: true,  course: nil, num_quiz_questions: 1,review_topic_threshold: 1
        create :assignment_due_date, due_at: (DateTime.now + 100),assignment: @assignment
        create :assignment_due_date, due_at: (DateTime.now + 100), assignment: @assignment,deadline_type:DeadlineType.where(name: 'review').first

        @participant1=create :participant, assignment: @assignment, user: @student1
        @team1 = create :assignment_team, assignment: @assignment,name:'quiz_team1_'+i.to_s
        create :team_user, team: @team1, user: @student1
        create :review_response_map, assignment: @assignment, reviewee: @team1,reviewer_id:@student1.id

        @participant2=create :participant, assignment: @assignment, user: @student2
        @team2 = create :assignment_team, assignment: @assignment,name:'quiz_team2_'+i.to_s
        create :team_user, team: @team2, user: @student2
    end

    # Create a team quiz questionnaire
    @questionnaire2 = create :quiz_questionnaire, instructor_id:Team.find_by(name:'quiz_team1_2').id,name:"quiz_test2"
    @questionnaire3 = create :quiz_questionnaire, instructor_id: Team.find_by(name:'quiz_team1_3').id,name:"quiz_test3"

    # Create the quiz question and answers
    choices = [
        create(:quiz_question_choice, question: @question, txt: 'Answer 1', iscorrect: 1),
        create(:quiz_question_choice, question: @question, txt: 'Answer 2'),
        create(:quiz_question_choice, question: @question, txt: 'Answer 3'),
        create(:quiz_question_choice, question: @question, txt: 'Answer 4')
    ]
    choices2 = [
        create(:quiz_question_choice, question: @question, txt: 'Answer 1', iscorrect: 1),
        create(:quiz_question_choice, question: @question, txt: 'Answer 2'),
        create(:quiz_question_choice, question: @question, txt: 'Answer 3'),
        create(:quiz_question_choice, question: @question, txt: 'Answer 4')
    ]
    @question2 = create :quiz_question, questionnaire: @questionnaire2, txt: 'quiz_Question_2', quiz_question_choices: choices
    @question3 = create :quiz_question, questionnaire: @questionnaire3, txt: 'quiz_Question_3', quiz_question_choices: choices2

    # Create a response mapping
    @response_map = create :quiz_response_map, quiz_questionnaire: @questionnaire3, reviewer_id: @participant2.id, reviewee_id: Team.find_by(name:'quiz_team1_3').id

    # Create a question response
    @response = create :quiz_response, response_map: @response_map

    # Create an answer for the question
    create :answer, question: @question3, response_id: @response.id, answer: 1
  end

  def assignment_due(type,time,round, review_allowed_id = 3)
    create(:assignment_due_date,
           deadline_type: DeadlineType.where(name: type).first,
           assignment:Assignment.find_by(name: "Assignment1665"),
           due_at: time,
           round: round,
           review_allowed_id: review_allowed_id)
  end

  def topic_due(type,time,id,round, review_allowed_id = 3)
    create(:topic_due_date,
           due_at: time,
           deadline_type: DeadlineType.where(name: type).first,
           topic: SignUpTopic.where(id: id).first,
           round: round,
           review_allowed_id: review_allowed_id)
  end


end