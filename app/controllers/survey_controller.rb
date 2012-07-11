class SurveyController < ApplicationController

  ###
  #  Assign a survey questionnaire to an assignment
  ###
  def assign
    #Get the Assignment record from the database and its associated surveys
    @assignment = Assignment.find(params[:id])
    @assigned_surveys = SurveyHelper::get_assigned_surveys(@assignment.id)

    #Get specific surveys associated to an instructor or simply default
    #to the surveys associated to the assignment, ie, @assigned_surveys above
    @surveys = getSurveys(params['subset'], @assigned_surveys)

    #Get a list of the surveys checked by the user. Note, the list only contains survey ids
    @checked_survey_ids = params[:surveys]

    #Get a list of all of the surveys submitted by the user
    @submitted_surveys = getSurveys(params['submit_subset'], @assigned_surveys)

    #Determine if the user is performing an update operation. If so, assign surveys or delete survey
    #assignments as noted by the user.
    if params['update']
      #Determine if the user has selected any surveys to associate with the assignment
      if @checked_survey_ids
        deleteUncheckedSurveysSpecific()    #Delete the association between surveys and assignments
        assignCheckedSurveys()              #Create an association between the checked survey and the assignment
      else
        deleteUncheckedSurveysAll()         #The user didn't check any surveys before submitting. Thus,
      end                                   #delete ALL survey-assignment associations.
    end

    @surveys.sort!{|a,b| a.name <=> b.name}
  end

private

  ###
  #   Get the surveys, aka, questionnaires from the database
  ###
  def getSurveys(survey_owner, assigned_surveys)
    if survey_owner == "mine"
      return Questionnaire.find(:all, :conditions => ["type = 'SurveyQuestionnaire' and instructor_id = ?", session[:user].id])
    elsif survey_owner == "public"
      return Questionnaire.find(:all, :conditions => ["type = 'SurveyQuestionnaire' and private = 0"])
    else
      return assigned_surveys
    end
  end

  ###
  #    Delete the survey-assignment association as noted by the user via the unchecked boxes
  ###
  def deleteUncheckedSurveysSpecific()
    for survey in @submitted_surveys
      unless @checked_survey_ids.include? survey.id
        AssignmentQuestionnaire.delete_all(["questionnaire_id = ? and assignment_id = ?", survey.id, @assignment.id])
        @assigned_surveys.delete(survey)
      end
    end
  end

  ###
  #   Delete all of the survey-assignment associations as noted by the user via the unchecked boxes
  ###
  def deleteUncheckedSurveysAll()
    for survey in @submitted_surveys
      AssignmentQuestionnaire.delete_all(["questionnaire_id = ? and assignment_id = ?", survey.id, @assignment.id])
      @assigned_surveys.delete(survey)
      @surveys.delete(survey)
    end
  end

  ###
  #  Create an association between the survey and the assignment as noted by the user via the selected
  #  check boxes
  ###
  def assignCheckedSurveys()
    for survey_id in @checked_survey_ids
      @current_survey = Questionnaire.find(survey_id)
      unless @assigned_surveys.include? @current_survey
        @new = AssignmentQuestionnaire.new(:questionnaire_id => survey_id, :assignment_id => @assignment.id)
        @new.save
        @assigned_surveys << @current_survey
      end
    end
  end

end
