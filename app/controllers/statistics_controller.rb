class StatisticsController < ApplicationController
  def list_surveys 
    @surveys = Questionnaire.find_all_by_type_id(4)
  end
  
  def list #list deployments for the survey
    @survey_id = params[:id]
    @deployment = SurveyDeployment.find_all_by_course_evaluation_id(@survey_id).map{|u| [u.start_date.to_s+" - "+u.end_date.to_s,u.id] }
  end
  def view_responses
    sd_id1=params[:statistics]["survey_deployment_id1"]
    sd_id2=params[:statistics]["survey_deployment_id2"]
    
    survey_id1=SurveyDeployment.find(sd_id1).course_evaluation_id
    @deployment_date1=SurveyDeployment.find(sd_id1).start_date.strftime('%A %B %d %Y, %I:%M%p') + "-" + SurveyDeployment.find(sd_id1).end_date.strftime('%A %B %d %Y, %I:%M%p')
    @deployment_date2=SurveyDeployment.find(sd_id2).start_date.strftime('%A %B %d %Y, %I:%M%p') + "-" + SurveyDeployment.find(sd_id2).end_date.strftime('%A %B %d %Y, %I:%M%p')
    
    @survey=Questionnaire.find(survey_id1)
    @questions=Question.find_all_by_questionnaire_id(survey_id1)
   
    @num_responses1=Hash.new
    @num_responses2=Hash.new
    @t_score=Hash.new  
    @questions.each do |q| # calculate number of responses for each question
      @num_responses1[q.id]=Hash.new
      total_question_response=SurveyResponse.find_all_by_survey_deployment_id_and_question_id(sd_id1,q.id).length
      for i in @survey.min_question_score..@survey.max_question_score
        if(total_question_response>0)
          @num_responses1[q.id][i]=(SurveyResponse.find(:all,:conditions=>["survey_deployment_id=? and question_id=? and score=?",sd_id1,q.id,i]).length.to_f/total_question_response)
        else 
          @num_responses1[q.id][i]=0.0
         end
      end
      
      @num_responses2[q.id]=Hash.new
      total_question_response=SurveyResponse.find_all_by_survey_deployment_id_and_question_id(sd_id2,q.id).length
      for i in @survey.min_question_score..@survey.max_question_score
       if(total_question_response>0)
        @num_responses2[q.id][i]=(SurveyResponse.find(:all,:conditions=>["survey_deployment_id=? and question_id=? and score=?",sd_id2,q.id,i]).length.to_f/total_question_response)
       else 
        @num_responses2[q.id][i]=0.0
        end
      end
      #calculate t-test score for the question
      @t_score[q.id]=t_test(@num_responses1[q.id],@num_responses2[q.id],@survey.min_question_score,@survey.max_question_score)
    end
      
    
  end

 def t_test(r1,r2,min,max) # The statistical t-test
   
   
   ex1=exx1=0.0
   ex2=exx2=0.0
    
   for i in min..max
     ex1+=i*r1[i]
     exx1+=i*i*r1[i]
     ex2+=i*r2[i]
     exx2+=i*i*r2[i]
   end
   
   logger.info r1
   logger.info r2
   logger.info "#{ex1} #{ex2} #{exx1} #{exx2}"
   
   #Calculate t-test score
   mean_diff=ex1-ex2
   s1=exx1-ex1*ex1
   s2=exx2-ex2*ex2
   
   if mean_diff==0 
     mean_diff
   else
     mean_diff/Math.sqrt(s1/r1.length + s2/r2.length)
   end
   
 end


end
