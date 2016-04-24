class SurveyController < ApplicationController

  def action_allowed?
    ['Instructor',
     'Teaching Assistant',
     'Administrator'].include? current_role_name
  end

  def assign
    @assignment = Assignment.find(params[:id])
    @assigned_surveys = SurveyHelper::get_assigned_surveys(@assignment.id)
    @surveys = Array.new

    if params['subset'] == "mine"
      @surveys = Questionnaire.where("type = ? and instructor_id = ?","SurveyQuestionnaire", session[:user].id)
    elsif params['subset'] == "public"
      @surveys = Questionnaire.where("type = ? and private = 0","SurveyQuestionnaire")
    else
      @surveys = @assigned_surveys
    end

    if params['update']
      if params[:surveys]
        @checked = params[:surveys]

        if params['submit_subset'] == "mine"
          @submit_surveys = Questionnaire.where("type = ? and instructor_id = ?","SurveyQuestionnaire", session[:user].id)
        elsif params['submit_subset'] == "public"
          @submit_surveys = Questionnaire.where("type = ? and private = 0","SurveyQuestionnaire")
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
    #@surveys.sort!{|a,b| a.name <=> b.name}
  end

    def course_survey
    @course = Course.find(params[:id])
    @assigned_surveys = SurveyHelper::get_course_surveys(@course.id)
    @surveys = Array.new

    if params['subset'] == "mine"
      @surveys = Questionnaire.where("type = ? or type = ? and instructor_id = ?","SurveyQuestionnaire","CourseEvaluationQuestionnaire", session[:user].id)
    elsif params['subset'] == "public"
      @surveys = Questionnaire.where("type = ? or type = ? and private = 0","SurveyQuestionnaire","CourseEvaluationQuestionnaire")
    else
      @surveys = @assigned_surveys
    end

    if params['update']
      if params[:surveys]
        @checked = params[:surveys]

        if params['submit_subset'] == "mine"
        @submit_surveys = Questionnaire.where("type = ? or type = ? and instructor_id= ?","SurveyQuestionnaire","CourseEvaluationQuestionnaire", session[:user].id)
        elsif params['submit_subset'] == "public"
         @submit_surveys = Questionnaire.where("type = ? or type = ? and private = 0","SurveyQuestionnaire","CourseEvaluationQuestionnaire")
        else
          @submit_surveys = @assigned_surveys
        end

        for survey in @submit_surveys
          unless @checked.include? survey.id
            SurveyDeployment.delete_all(["course_evaluation_id = ? and course_id = ?", survey.id, @course.id])
            @assigned_surveys.delete(survey)
          end
        end

        for checked_survey in @checked
          @current = Questionnaire.find(checked_survey)
          unless @assigned_surveys.include? @current
            @sd = Time.now + 100
            @ed = Time.now + 250000
            @new = SurveyDeployment.new(:course_evaluation_id => @current.id, :course_id => @course.id, :num_of_students => 0, :start_date => @sd, :end_date => @ed)
            @new.save
            @assigned_surveys << @current
          end
        end
      else
        for survey in @submit_surveys
          SurveyDeployment.delete_all(["course_evaluation_id = ? and course_id = ?", survey.id, @course.id])
          @assigned_surveys.delete(survey)
          @surveys.delete(survey)
        end
      end
    end
    
  end

  def survey_add_global
	@global_surveys = SurveyHelper::get_global_surveys
        @survey = Questionnaire.find_by(id: params[:id])
        @course = Course.find_by(id: params[:course])
        @assigned_surveys = GlobalSurveyMapHelper::get_assigned_global_surveys(@course.id,@survey.id)
        if params['update']
        if params[:surveys]
        @checked = params[:surveys]

       
        for survey in @global_surveys
          unless @checked.include? survey.id
            GlobalSurveyMap.delete_all(["global_surveys_id = ? and courses_id = ? and surveys_id = ?", survey.id, @course.id, @survey.id])
            @assigned_surveys.delete(survey)
          end
        end

        for checked_survey in @checked
          @current = Questionnaire.find(checked_survey)
          unless @assigned_surveys.include? @current
            @new = GlobalSurveyMap.new(:global_surveys_id => checked_survey, :courses_id => @course.id, :surveys_id => @survey.id)
            @new.save
            @assigned_surveys << @current
          end
        end
      else
        for survey in @assigned_surveys
          GlobalSurveyMap.delete_all(["global_surveys_id = ? and courses_id = ? and surveys_id = ?", survey.id, @course.id, @survey.id])
          @assigned_surveys.delete(survey)
        end
      end
    end

        
  end

  def survey_add_students
        @survey = Questionnaire.find_by(id: params[:id])
        @course = Course.find_by(id: params[:course])
        @deployment = SurveyDeployment.where("course_id = ? and course_evaluation_id = ?",@course.id,@survey.id)
        @instructor = session[:user]
        @course_students = Participant.where(parent_id: @course.id)
        @assigned_students = SurveyParticipantHelper::get_assigned_survey_students(@deployment[0].id)
        if params['update']
        if params[:students]
        @checked = params[:students]

       
        for student in @course_students
          unless @checked.include? student.id
            SurveyParticipant.delete_all(["user_id = ? and survey_deployment_id = ?",student.id,@deployment[0].id])
            @assigned_students.delete(student)
          end
        end

        for checked_student in @checked
          @current = Participant.find(checked_student)
          unless @assigned_students.include? @current
            @user_id = @current.user_id
            @new = SurveyParticipant.new(:user_id => @user_id, :survey_deployment_id => @deployment[0].id)
            @new.save
            @assigned_students << @current
          end
        end
      else
        for student in @assigned_students
          SurveyParticipant.delete_all(["user_id = ? and survey_deployment_id = ?",student.id,@deployment[0].id])
          @assigned_students.delete(student)
        end
      end
    end

        
  end

  def edit_deployment
        @survey = Questionnaire.find_by(id: params[:id])
        @course = Course.find_by(id: params[:course])
        @deployment = SurveyDeployment.where("course_id = ? and course_evaluation_id = ?",@course.id,@survey.id)
        @deploy = @deployment[0]
  end

  def update_deployment
       @deploy = SurveyDeployment.find_by(id: params[:deploy][:deploy_id])
       @deploy.update_attribute(:start_date,params[:deploy][:start_date])
       @deploy.update_attribute(:end_date,params[:deploy][:end_date])
       
  end

end
