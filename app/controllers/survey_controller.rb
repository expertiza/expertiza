class SurveyController < ApplicationController

  def assign
    @assignment = Assignment.find(params[:id])
    @assigned_surveys = SurveyHelper::get_assigned_surveys(@assignment.id)
    @surveys = Array.new
    
    if params['subset'] == "mine"
      @surveys = Questionnaire.find(:all, :conditions => ["type_id = 2 and instructor_id = ?", session[:user].id])
    elsif params['subset'] == "public"
      @surveys = Questionnaire.find(:all, :conditions => ["type_id = 2 and private = 0"])
    else
      @surveys = @assigned_surveys
    end
    
    if params['update']
      if params[:surveys]
        @checked = params[:surveys]
        
        if params['submit_subset'] == "mine"
          @submit_surveys = Questionnaire.find(:all, :conditions => ["type_id = 2 and instructor_id = ?", session[:user].id])
        elsif params['submit_subset'] == "public"
          @submit_surveys = Questionnaire.find(:all, :conditions => ["type_id = 2 and private = 0"])
        else
          @submit_surveys = @assigned_surveys
        end
        
        for survey in @submit_surveys
          unless @checked.include? survey.id
            AssignmentQuestionnaire.delete_all(["questionnaire_id = ? and assignment_id = ?", survey.id, @assignment.id])
            @assigned_surveys.delete(survey)
          end
        end 
        
        for checked_survey in @checked
          @current = Questionnaire.find(checked_survey)
          unless @assigned_surveys.include? @current
            @new = AssignmentQuestionnaire.new(:questionnaire_id => checked_survey, :assignment_id => @assignment.id)
            @new.save
            @assigned_surveys << @current
          end
        end
      else
        for survey in @submit_surveys
          AssignmentQuestionnaire.delete_all(["questionnaire_id = ? and assignment_id = ?", survey.id, @assignment.id])
          @assigned_surveys.delete(survey)
          @surveys.delete(survey)
        end 
      end
    end    
    @surveys.sort!{|a,b| a.name <=> b.name}
  end
  
  

end
