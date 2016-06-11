class SurveyController < ApplicationController
  def action_allowed?
    ['Instructor',
     'Teaching Assistant',
     'Administrator'].include? current_role_name
  end

  def assign
    @assignment = Assignment.find(params[:id])
    @assigned_surveys = SurveyHelper.get_assigned_surveys(@assignment.id)
    @surveys = []

    @surveys = if params['subset'] == "mine"
                 Questionnaire.where(["type_id = 2 and instructor_id = ?", session[:user].id])
               elsif params['subset'] == "public"
                 Questionnaire.where(["type_id = 2 and private = 0"])
               else
                 @assigned_surveys
               end

    if params['update']
      if params[:surveys]
        @checked = params[:surveys]

        @submit_surveys = if params['submit_subset'] == "mine"
                            Questionnaire.where(["type_id = 2 and instructor_id = ?", session[:user].id])
                          elsif params['submit_subset'] == "public"
                            Questionnaire.where(["type_id = 2 and private = 0"])
                          else
                            @assigned_surveys
                          end

        for survey in @submit_surveys
          unless @checked.include? survey.id
            AssignmentQuestionnaire.delete_all(["questionnaire_id = ? and assignment_id = ?", survey.id, @assignment.id])
            @assigned_surveys.delete(survey)
          end
        end

        for checked_survey in @checked
          @current = Questionnaire.find(checked_survey)
          next if @assigned_surveys.include? @current
          @new = AssignmentQuestionnaire.new(questionnaire_id: checked_survey, assignment_id: @assignment.id)
          @new.save
          @assigned_surveys << @current
        end
      else
        for survey in @submit_surveys
          AssignmentQuestionnaire.delete_all(["questionnaire_id = ? and assignment_id = ?", survey.id, @assignment.id])
          @assigned_surveys.delete(survey)
          @surveys.delete(survey)
        end
      end
    end
    @surveys.sort! {|a, b| a.name <=> b.name }
  end
end
