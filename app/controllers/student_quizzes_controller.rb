class StudentQuizzesController < ApplicationController

  def action_allowed?
    ['Administrator',
     'Instructor',
     'Teaching Assistant'].include? current_role_name or (current_role_name.eql?("Student") and ((%w(index).include? action_name) ? are_needed_authorizations_present? : true))

  end

  def index
    @participant = AssignmentParticipant.find(params[:id])
    return unless current_user_id?(@participant.user_id)
    @assignment = Assignment.find(@participant.parent_id)
    @quiz_mappings = QuizResponseMap.get_mappings_for_reviewer(@participant.id)
  end

  def finished_quiz
    @response = Response.where(map_id: params[:map_id]).first
    @response_map = ResponseMap.find(params[:map_id])
    @questions = Question.where(questionnaire_id: @response_map.reviewed_object_id) #for quiz response map, the reivewed_object_id is questionnaire id
    @map = ResponseMap.find(params[:map_id])
    @participant = AssignmentTeam.find(@map.reviewee_id).participants.first

    quiz_score = 0.0

    @questions.each do |question|
      score = Answer.where(response_id: @response.id, question_id:  question.id).first
      if score.answer.eql? -1
        #This used to be designed for ungraded essay question.
      else
        quiz_score += score.answer
      end
    end

    question_count = @questions.length

    @quiz_score = (quiz_score/question_count) * 100
  end

  #Create an array of candidate quizzes for current reviewer
  def self.take_quiz assignment_id , reviewer_id
    quizzes = Array.new
    reviewer = Participant.where(user_id: reviewer_id, parent_id: assignment_id).first
    reviewed_team_response_maps = ReviewResponseMap.where(reviewer_id:reviewer.id)
    reviewed_team_response_maps.each do |team_response_map_record|
      reviewee_id=team_response_map_record.reviewee_id
      reviewee_team = Team.find(reviewee_id) #reviewees should always be teams
      if reviewee_team.parent_id!=assignment_id
        next
      end
      quiz_questionnaire = QuizQuestionnaire.where(instructor_id:reviewee_team.id).first

      #if the reviewee team has created quiz
      if quiz_questionnaire
        if !quiz_questionnaire.taken_by? reviewer
          quizzes << quiz_questionnaire
        end
      end
    end
    quizzes
  end

  def calculate_score map, response
    questionnaire = Questionnaire.find(map.reviewed_object_id)
    scores = Array.new
    valid = true
    questions = Question.where(questionnaire_id: questionnaire.id)
    questions.each do |question|
      score = 0
      correct_answers = QuizQuestionChoice.where(question_id: question.id, iscorrect: true)
      ques_type = question.type
      if ques_type.eql? 'MultipleChoiceCheckbox'
        if params["#{question.id}"].nil?
          valid = false
        else
          params["#{question.id}"].each do |choice|
          #loop the quiz taker's choices and see if 1)all the correct choice are checked and 2) # of quiz taker's choice matches the # of the correct choices
            correct_answers.each do |correct|
              if choice.eql? correct.txt
                score += 1
              end
            end
          end
          if score== correct_answers.count && score == params["#{question.id}"].count
            score = 1
          else
            score = 0
          end
          #for MultipleChoiceCheckbox, score =1 means the quiz taker have done this question correctly, not just make select this choice correctly.
          params["#{question.id}"].each do |choice|
            new_score = Answer.new comments: choice, question_id: question.id, response_id: response.id, :answer => score

            unless new_score.valid?
              valid = false
            end
            scores.push(new_score)
          end
        end
      else #TrueFalse and MultipleChoiceRadio
        correct_answer = correct_answers.first
        if correct_answer.txt==params["#{question.id}"]
          score=1
        else
          score=0
        end
        new_score = Answer.new :comments => params["#{question.id}"], :question_id => question.id, :response_id => response.id, :answer => score
        if new_score.nil? || new_score.comments.nil? || new_score.comments.empty?
          valid = false
        end
        scores.push(new_score)
      end
    end
    if valid
      scores.each do |score|
        score.save
      end
      redirect_to :controller => 'student_quizzes', :action => 'finished_quiz', :map_id => map.id
    else
      response.destroy
      flash[:error] = "Please answer every question."
      redirect_to :action => :take_quiz, :assignment_id => params[:assignment_id], :questionnaire_id => questionnaire.id, :map_id => map.id
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

      calculate_score map,response
    else
      flash[:error] = "You have already taken this quiz, below are the records for your responses."
      redirect_to :controller => 'student_quizzes', :action => 'finished_quiz', :map_id => map.id
    end

  end

  def graded?(response, question)
    return (Answer.where(question_id: question.id, response_id:  response.id).first)
  end

  #This method is only for quiz questionnaires, it is called when instructors click "view quiz questions" on the pop-up panel.
  def review_questions
    @assignment_id = params[:id]
    @quiz_questionnaires = Array.new
    Team.where(parent_id: params[:id]).each do |quiz_creator|
      Questionnaire.where(instructor_id: quiz_creator.id).each do |questionnaire|
        @quiz_questionnaires.push questionnaire
      end
    end
  end

  private
  #authorizations: reader,submitter, reviewer
  def are_needed_authorizations_present?
    @participant = Participant.find(params[:id])
    authorization = Participant.get_authorization(@participant.can_submit, @participant.can_review, @participant.can_take_quiz)
    if authorization == 'reviewer' or authorization == 'submitter'
      return false
    else
      return true
    end
  end

end
