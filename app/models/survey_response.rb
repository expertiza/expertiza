class SurveyResponse < ActiveRecord::Base
  belongs_to :assignment
  belongs_to :questionnaire
  belongs_to :question

  def self.get_survey_response(assignmentID, surveyId, questionId, emailId)
    list = []
    list = SurveyResponse.where( ["assignment_id = ? and survey_id = ? and question_id = ? and email = ?", assignmentID, surveyId, questionId, emailId]) if emailId
    if list.length > 0
      @new = list[0]
    else
      @new = SurveyResponse.new
    end
    @new.survey_id = params[:survey_id]
    @new.question_id = question.id
    @new.assignment_id = params[:id]
    @new.email = params[:email]
    @new.score = @scores[question.id.to_s]
    @new.comments = @comments[question.id.to_s]
    @new.save
  end

  def self.get_survey_list(assignment_id, survey_id)
    survey_list = SurveyResponse.where( ["assignment_id = ? and survey_id = ?", assignment_id, survey_id])
    return survey_list
  end

  def self.get_survey_list_with_deploy_id(deployment_id, survey_id)
    survey_list = SurveyResponse.where( ["survey_deployment_id = ? and survey_id = ?", deployment_id, survey_id])
    return survey_list
  end

  def self.get_survey_list_with_score(assignment_id, survey_id, question_id, score)
    survey_list = SurveyResponse.where( ["assignment_id = ? and survey_id = ? and question_id = ? and score = ?", assignment_id, survey_id, question_id, score])
    return survey_list
  end

  def self.get_survey_list_with_deploy_id_and_score(deployment_id, survey_id, question_id, score)
    survey_list = SurveyResponse.where( ["survey_deployment_id = ? and survey_id = ? and question_id = ? and score = ?", deployment_id, survey_id, question_id, score])
    return survey_list
  end

  def self.get_no_of_questions_with_assignment_id(assignment_id, survey_id, question_id)
    no_of_question = SurveyResponse.where( ["assignment_id = ? and survey_id = ? and question_id = ?", assignment_id, survey_id, question_id])
    return no_of_question
  end

  def self.get_no_of_questions_with_deployment_id(deployment_id, survey_id, question_id)
    no_of_question = SurveyResponse.where( ["survey_deployment_id = ? and survey_id = ? and question_id = ?", deployment_id, survey_id, question_id])
    return no_of_question
  end

  def self.get_responses_comments_with_assignment_id(assignment_id, survey_id, question_id)
    @responses = SurveyResponse.where( ["assignment_id = ? and survey_id = ? and question_id = ?", assignment_id, survey_id, question_id]).order("score")
    return @responses
  end


  def self.get_responses_comments_with_deployment_id(deployment_id, survey_id, question_id)
    @responses = SurveyResponse.where( ["survey_deployment_id = ? and survey_id = ? and question_id = ?", deployment_id, survey_id, question_id]).order("score")
    return @responses
  end




end
