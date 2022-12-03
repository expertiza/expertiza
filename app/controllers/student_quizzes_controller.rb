class StudentQuizzesController < ApplicationController
  include AuthorizationHelper
  include StudentQuizzesHelper
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
    @participant = AssignmentParticipant.find(params[:id])
    return unless current_user_id?(@participant.user_id)   #checks if logged in user is not a participant
    @assignment = Assignment.find(@participant.parent_id)
    @quiz_mappings = QuizResponseMap.mappings_for_reviewer(@participant.id) #returns quizzes to be reviewed by participant
  end

 # Populating Quiz Response Data
  def finished_quiz
    @participant_response = Response.where(map_id: params[:map_id]).first 
    @quiz_response_map = QuizResponseMap.find(params[:map_id])
    @quiz_questions = Question.where(questionnaire_id: @quiz_response_map.reviewed_object_id)
    response_map = ResponseMap.find(params[:map_id])
    @participant = AssignmentTeam.find(response_map.reviewee_id).participants.first #Populating participant who gave the quiz
    @participant_quiz_score = @quiz_response_map.quiz_score #Populating quiz score of the Participant
  end

  # Return an array of quiz questions for reviewer with reviewer_id
  def self.get_quiz_questionnaire(assignment_id, reviewer_id)
    quiz_questions = []
    reviewer = Participant.where(user_id: reviewer_id, parent_id: assignment_id).first
    reviewed_team_response_maps = ReviewResponseMap.where(reviewer_id: reviewer.id) # Get reviewed_team_response_maps based on reviewer_id
    reviewed_team_response_maps.each do |team_response_map_record|
      reviewee_id = team_response_map_record.reviewee_id
      reviewee_team = Team.find(reviewee_id) # Get team of the reviewer
      next unless reviewee_team.parent_id == assignment_id
      quiz_questionnaire = QuizQuestionnaire.where(instructor_id: reviewee_team.id).first # Get the latest quiz questions of the team of reviewer
      # if the reviewee team has created quiz
      if quiz_questionnaire
        quiz_questions << quiz_questionnaire unless quiz_questionnaire.taken_by? reviewer
      end
    end
    quiz_questions
  end

  # check if there is any response for this map_id. This is to prevent student take same quiz twice
  def save_quiz_response
    participant_response = ResponseMap.find(params[:map_id])
    if participant_response.response.empty? # If there is no instance of the response of the student, create new and save.
      response = Response.new
      response.map_id = params[:map_id]
      response.created_at = DateTime.current
      response.updated_at = DateTime.current
      response.save
      score_response = calculate_score participant_response, response
      if score_response["valid"]
        score_response["scores"].each(&:save)
        redirect_to controller: 'student_quizzes', action: 'finished_quiz', map_id: participant_response.id
      else
        score_response["quiz_response"].destroy
        flash[:error] = 'Please answer every question.'
        questionnaire = Questionnaire.find(participant_response.reviewed_object_id)
        redirect_to action: :take_quiz, assignment_id: params[:assignment_id], questionnaire_id: questionnaire.id, map_id: participant_response.id
      end
    else  #Quiz is already taken.
      flash[:error] = 'You have already taken this quiz, below are your responses.'
      redirect_to controller: 'student_quizzes', action: 'finished_quiz', map_id: participant_response.id
    end
  end


  # This method is only for quiz questionnaires, it is called when instructors click "view quiz questions" on the pop-up panel.
  # def review_questions
  #   @quiz_creator_user_id = params[:id]
  #   @quiz_questionnaires = []
  #   Team.where(parent_id: params[:id]).each do |quiz_creator| #Get all teams of participant who created quizzes
  #     Questionnaire.where(instructor_id: quiz_creator.id).each do |questionnaire| #Get all quizzes of the team
  #       @quiz_questionnaires.push questionnaire #Populate all the questionnaire of a quiz
  #     end
  #   end
  # end
end
