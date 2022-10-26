class StudentQuizzesController < ApplicationController
  include AuthorizationHelper

  #Checks authorization for any action based on user type: Student or Teaching Assistant
  def action_allowed?
    if current_user_is_a? 'Student'
      if action_name.eql? 'index' #For Student, check if student has authorizations of reviewer & submitter
        are_needed_authorizations_present?(params[:id], 'reviewer', 'submitter')
      else
        true #returns true for any action other than 'index'
      end
    else
      current_user_has_ta_privileges? #check if user is Teaching Assistant
    end
  end

  #Returns quizzes to be reviewed for a participant
  def index
    @participant = AssignmentParticipant.find(params[:id]) #Get participant object
    return unless current_user_id?(@participant.user_id)   #checks if logged in user is not a participant
    @assignment = Assignment.find(@participant.parent_id)  #Get assignment created by parent_id
    @quiz_mappings = QuizResponseMap.mappings_for_reviewer(@participant.id) #returns quizzes to be reviewed by participant
  end

 # Populating Quiz Response Data
  def finished_quiz
    @participant_response = Response.where(map_id: params[:map_id]).first # Populating participant response
    @quiz_response_map = QuizResponseMap.find(params[:map_id]) #Populating Quiz Response
    @quiz_questions = Question.where(questionnaire_id: @quiz_response_map.reviewed_object_id) #Populating Quiz Questions
    response_map = ResponseMap.find(params[:map_id]) #Populating ResponseMap
    @participant = AssignmentTeam.find(response_map.reviewee_id).participants.first #Populating participant who gave the quiz
    @participant_quiz_score = @quiz_response_map.quiz_score #Populating quiz score of the Participant
  end

  # Create an array of candidate quizzes for current reviewer
  def self.take_quiz(assignment_id, reviewer_id)
    quizzes = []
    reviewer = Participant.where(user_id: reviewer_id, parent_id: assignment_id).first
    reviewed_team_response_maps = ReviewResponseMap.where(reviewer_id: reviewer.id)
    reviewed_team_response_maps.each do |team_response_map_record|
      reviewee_id = team_response_map_record.reviewee_id
      reviewee_team = Team.find(reviewee_id) # reviewees should always be teams
      next unless reviewee_team.parent_id == assignment_id

      quiz_questionnaire = QuizQuestionnaire.where(instructor_id: reviewee_team.id).first

      # if the reviewee team has created quiz
      if quiz_questionnaire
        quizzes << quiz_questionnaire unless quiz_questionnaire.taken_by? reviewer
      end
    end
    quizzes
  end

  # the way 'answers' table store the results of quiz
  def calculate_score(map, response)
    questionnaire = Questionnaire.find(map.reviewed_object_id)
    scores = []
    valid = true
    questions = Question.where(questionnaire_id: questionnaire.id)
    questions.each do |question|
      score = 0
      correct_answers = QuizQuestionChoice.where(question_id: question.id, iscorrect: true)
      ques_type = question.type
      if ques_type.eql? 'MultipleChoiceCheckbox'
        if params[question.id.to_s].nil?
          valid = false
        else
          params[question.id.to_s].each do |choice|
            # loop the quiz taker's choices and see if 1)all the correct choice are checked and 2) # of quiz taker's choice matches the # of the correct choices
            correct_answers.each do |correct|
              score += 1 if choice.eql? correct.txt
            end
          end
          score = score == correct_answers.count && score == params[question.id.to_s].count ? 1 : 0
          # for MultipleChoiceCheckbox, score =1 means the quiz taker have done this question correctly, not just make select this choice correctly.
          params[question.id.to_s].each do |choice|
            new_score = Answer.new comments: choice, question_id: question.id, response_id: response.id, answer: score
            valid = false unless new_score.valid?
            scores.push(new_score)
          end
        end
      else # TrueFalse and MultipleChoiceRadio
        correct_answer = correct_answers.first
        score = correct_answer.txt == params[question.id.to_s] ? 1 : 0
        new_score = Answer.new comments: params[question.id.to_s], question_id: question.id, response_id: response.id, answer: score
        valid = false if new_score.nil? || new_score.comments.nil? || new_score.comments.empty?
        scores.push(new_score)
      end
    end
    if valid
      scores.each(&:save)
      redirect_to controller: 'student_quizzes', action: 'finished_quiz', map_id: map.id
    else
      response.destroy
      flash[:error] = 'Please answer every question.'
      redirect_to action: :take_quiz, assignment_id: params[:assignment_id], questionnaire_id: questionnaire.id, map_id: map.id
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

      calculate_score map, response
    else
      flash[:error] = 'You have already taken this quiz, below are the records for your responses.'
      redirect_to controller: 'student_quizzes', action: 'finished_quiz', map_id: map.id
    end
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
