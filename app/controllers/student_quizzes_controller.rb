class StudentQuizzesController < ApplicationController
  include AuthorizationHelper

  def action_allowed?
    if current_user_is_a? 'Student'
      if action_name.eql? 'index'
        are_needed_authorizations_present?(params[:id], 'reviewer', 'submitter')
      else
        true
      end
    else
      current_user_has_ta_privileges?
    end
  end

# INDEX
# Finds an assignment participants
# Do not show assignment or quizzes if current user not a participant
# List assignments if participant involved as assignment's submitter or reviewer
  def index
    @participant = AssignmentParticipant.find(params[:id])
    return unless current_user_id?(@participant.user_id)

    @assignment = Assignment.find(@participant.parent_id)
    @quiz_mappings = QuizResponseMap.mappings_for_reviewer(@participant.id)
  end


  def finished_quiz
    @participant_response = Response.where(map_id: params[:map_id]).first #What is the purpose of @response? I don't see it used anywhere else in this file.
    #@participant_response is used in finished_quiz.html.erb
    @response_map = QuizResponseMap.find(params[:map_id])
    @quiz_questions = Question.where(questionnaire_id: @response_map.reviewed_object_id) # The reviewed_object_id is questionnaire_id for quiz response_map
    @map = ResponseMap.find(params[:map_id])
    @participant = AssignmentTeam.find(@map.reviewee_id).participants.first

    @quiz_score = @response_map.quiz_score
  end

  def self.take_quiz(assignment_id, reviewer_id)
    # Initialize an empty array to store quizzes
    quizzes = []
    # Find the participant with assignment_id and reviewer_id
    reviewer = Participant.where(user_id: reviewer_id, parent_id: assignment_id).first
    # Find  review response maps of the reviewer
    reviewed_team_response_maps = ReviewResponseMap.where(reviewer_id: reviewer.id)
    # Iterate each review response map
    reviewed_team_response_maps.each do |team_response_map_record|
      reviewee_id = team_response_map_record.reviewee_id
      reviewee_team = Team.find(reviewee_id) # reviewees should always be teams
      # Check if the reviewee team is associated with the given assignment_id
      next unless reviewee_team.parent_id == assignment_id

      # Find the quiz quiz associated with the reviewee team's instructor
      quiz_questionnaire = QuizQuestionnaire.where(instructor_id: reviewee_team.id).first

      if quiz_questionnaire
        quizzes << quiz_questionnaire unless quiz_questionnaire.taken_by? reviewer
      end
    end
    # Return the array available of quizzes
    quizzes
  end

  def calculate_score(map, response)
    quiz = Questionnaire.find(map.reviewed_object_id)
    scores = []
    valid_flag = true # Flag to track if user responses are valid
    questions = Question.where(questionnaire_id: quiz.id) # Get all questions of the quiz
    questions.each do |question|
      score = 0
      # Get correct answer(s) for the question
      correct_answers = QuizQuestionChoice.where(question_id: question.id, iscorrect: true)
      #Get the question type to grade (MultipleChoiceCheckbox, MultipleChoiceRadio or True/False)
      question_type = question.type
      #Grading logic for MultipleChoiceCheckbox
      if question_type.eql? 'MultipleChoiceCheckbox'
        #Checking if answer is blank
        if params[question.id.to_s].nil?
          valid_flag = false
        else
          params[question.id.to_s].each do |choice|
            # loop the quiz taker's choices and see if 1)all the correct choice are checked and 2) # of quiz taker's choice matches the # of the correct choices
            correct_answers.each do |correct|
              score += 1 if choice.eql? correct.txt
            end
          end
          # Create Answer objects for each choice selected by the user and validate them
          score = score == correct_answers.count && score == params[question.id.to_s].count ? 1 : 0
          # for MultipleChoiceCheckbox, score =1 means the quiz taker have done this question correctly, each_answer_score is set for each of the multiple answers selected
          params[question.id.to_s].each do |choice|
            each_answer_score = Answer.new comments: choice, question_id: question.id, response_id: response.id, answer: score
            valid_flag = false unless each_answer_score.valid?
            # Add the the each_answer_score object to the scores array
            scores.push(each_answer_score)
          end
        end
        # TrueFalse and MultipleChoiceRadio logic
      else
        # Get the correct answer
        correct_answer = correct_answers.first
        # Check if user's response matches the correct answer, set score to 1 if correct, else 0
        score = correct_answer.txt == params[question.id.to_s] ? 1 : 0
        new_score = Answer.new comments: params[question.id.to_s], question_id: question.id, response_id: response.id, answer: score
        valid_flag = false if new_score.nil? || new_score.comments.nil? || new_score.comments.empty?
        scores.push(new_score) # Add the Answer object to the scores array
      end
    end
    # Check if all user responses are valid_flag
    if valid_flag
      scores.each(&:save)
      redirect_to controller: 'student_quizzes', action: 'finished_quiz', map_id: map.id
      #Show error if not all answers are done
    else
      response.destroy
      flash[:error] = 'Please answer every question.'
      redirect_to action: :take_quiz, assignment_id: params[:assignment_id], questionnaire_id: quiz.id, map_id: map.id
    end
  end

  def record_response
    map = ResponseMap.find(params[:map_id])
    # check if there is any response for this map_id. This is to prevent student take same quiz twice
    if map.response.empty?
      response = Response.new
      response.map_id = params[:map_id]
      response.created_at = DateTime.current
      response.updated_at = DateTime.current
      response.save

      score = calculate_score map, response

      # Added logic to test for invalid scores to ensure redirect was happening
      if score.to_i < 0
        response.destroy  # Assuming you want to destroy the response if the score is invalid
        flash[:error] = 'An error occurred while calculating your score.'

        redirect_to controller: 'student_quizzes', action: 'get_quiz_questionnaire' # or wherever we need to redirect for invalid score
      end
      # end of added logic
    else
      flash[:error] = 'You have already taken this quiz, below are the records for your responses.'
      redirect_to controller: 'student_quizzes', action: 'finished_quiz', map_id: map.id
    end
  end

  def graded?(response, question)
    Answer.where(question_id: question.id, response_id: response.id).first
  end

  # This method is only for quiz questionnaires, it is called when instructors click "view quiz questions" on the pop-up panel.
  def review_questions
    @assignment_id = params[:id]
    @quiz_questionnaires = []
    Team.where(parent_id: params[:id]).each do |quiz_creator|
      Questionnaire.where(instructor_id: quiz_creator.id).each do |questionnaire|
        @quiz_questionnaires.push questionnaire
      end
    end
  end
end
