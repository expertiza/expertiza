class StudentQuizzesController < ApplicationController
  include AuthorizationHelper
  include StudentQuizzesHelper

  # Based on the logged in user, verifies user's authourizations and privileges
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

  # Initializes instance variables needed to fetch the necessary details of the quizzes.
  def index
    @participant = AssignmentParticipant.find(params[:id])
    return unless current_user_id?(@participant.user_id)

    @assignment = Assignment.find(@participant.parent_id)
    @quiz_mappings = QuizResponseMap.mappings_for_reviewer(@participant.id)
  end

  # For the response provided, this methods displays the questions, right/wrong answers and the final score.
  def finished_quiz
    @response = Response.where(map_id: params[:map_id]).last
    @response_map = QuizResponseMap.find(params[:map_id])
    # for quiz response map, the reivewed_object_id is questionnaire id
    @questions = Question.where(questionnaire_id: @response_map.reviewed_object_id)
    @quiz_response_map = ResponseMap.find(params[:map_id])
    @quiz_taker = AssignmentTeam.find(@quiz_response_map.reviewee_id).participants.first

    @quiz_score = @response_map.quiz_score
  end

  # Lists all the available quizzes created by the other teams in the current project which can be attempted.
  def self.take_quiz(assignment_id, reviewer_id)
    quizzes = []
    reviewer = Participant.where(user_id: reviewer_id, parent_id: assignment_id).first
    reviewed_team_response_maps = ReviewResponseMap.where(reviewer_id: reviewer.id)
    reviewed_team_response_maps.each do |team_response_map_record|
      reviewee_id = team_response_map_record.reviewee_id
      # reviewees should always be teams
      reviewee_team = Team.find(reviewee_id)
      next unless reviewee_team.parent_id == assignment_id

      quiz_questionnaire = QuizQuestionnaire.where(instructor_id: reviewee_team.id).first

      # if the reviewee team has created quiz
      if quiz_questionnaire
        quizzes << quiz_questionnaire unless quiz_questionnaire.taken_by? reviewer
      end
    end
    quizzes
  end

  # Stores the answers entered by the quiz taker and calculates the score based on the answers entered.
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
      flash[:error] = 'You have already taken this quiz. Below are the responses of your previous attempt.'
      redirect_to controller: 'student_quizzes', action: 'finished_quiz', map_id: map.id
    end
  end

  # This method is only for quiz questionnaires, it is called when instructors click "view quiz questions" on the pop-up panel.
  # Using the current assignment id parameter, fetches all the questions for each quiz and finally lists all the answers and scores for each submission.
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
