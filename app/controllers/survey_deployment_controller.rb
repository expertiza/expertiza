
class SurveyDeploymentController < ApplicationController


  def new 
    @surveys=Questionnaire.find_all_by_type_id(4).map{|u| [u.name, u.id] }
    @course = Course.find_all_by_instructor_id(session[:user].id).map{|u| [u.name, u.id] }
    @total_students = CourseParticipant.find_all_by_parent_id(@course[0].id).count
  end

  def create
    survey_deployment=params[:survey_deployment]
    
    @survey_deployment=SurveyDeployment.new(survey_deployment)
    if(params[:random_subset]["value"]=="1")
      @survey_deployment.num_of_students=User.find_all_by_role_id(1).length * rand
    end
    
    if(@survey_deployment.save)
      add_participants(@survey_deployment.num_of_students,@survey_deployment.id)
      redirect_to :action=>'list'
     else
      @surveys=QuestionnaireType.find_all_by_id(4).map{|u| [u.name, u.id] }
      @total_students=User.find_all_by_role_id(1).length
      @course = Course.find_all_by_instructor_id(session[:user].id).map{|u| [u.title, u.id] }
      render(:action=>'new')
     end     
  end
  
  def list
    @survey_deployments=SurveyDeployment.find(:all)
    @surveys={}
    @survey_deployments.each do |sd|
      @surveys[sd.id]=Questionnaire.find(sd.course_evaluation_id).name
    end
  end
  
  
   
   def delete
     SurveyDeployment.find(params[:id]).destroy
     SurveyParticipant.find_all_by_survey_deployment_id(params[:id]).each do |sp|
       sp.destroy
     end
     SurveyResponse.find_all_by_survey_deployment_id(params[:id]).each do |sr|
       sr.destroy
     end
     redirect_to :action=>'list'
   end
 
   def add_participants(num_of_participants,survey_deployment_id) #Add participants
    users=User.find_all_by_role_id(1)
    users_rand=users.sort_by{rand} #randomize user list
    num_of_participants.times do |i|
      survey_participant=SurveyParticipant.new
      survey_participant.user_id=users_rand[i].id
      survey_participant.survey_deployment_id=survey_deployment_id
      survey_participant.save
    end
       
  end
  
  def reminder_thread 
  
    #Check status of  reminder thread
    @reminder_thread_status="Running"
   unless MiddleMan.get_worker(session[:reminder_key])
        @reminder_thread_status="Not Running"
    end
   
  end
   
  def toggle_reminder_thread
    #Create reminder thread using BackgroundRb or kill it if its already running
   unless MiddleMan.get_worker(session[:reminder_key])
    session[:reminder_key]=MiddleMan.new_worker :class=>:reminder_worker, :args=>{:num_reminders=>3} # 3 reminders for now
   else
    MiddleMan.delete_worker(session[:reminder_key])
    session[:reminder_key]=nil
   end
   redirect_to :action=>'reminder_thread'
  end
   
def reportgen
  @assgn = []
  @scores = []
  @ranges = []
  @type = []
  @teams = []
  @user = User.new(params[:userform])
  @res = User.find_by_name(@user.name)
  if @user.name!=""
  @participant = Participant.find_all_by_user_id(@res.id)
  for participant in @participant do
    @temp=ScoreCache.find_all_by_reviewee_id(participant.id)
    @teams=AssignmentParticipant.find(:all, :conditions => ["parent_id=? and user_id=?", participant.parent_id, participant.user_id])
    puts @temp.size
    puts @teams.size
    for tscore in @temp do
      @assgn<<Assignment.find(participant.parent_id).name
      @scores<<tscore.score
      @ranges<<tscore.range
      @type<<tscore.object_type
    end
    for team in @teams do
      @temp=ScoreCache.find_all_by_reviewee_id(team.team)
    end
    for tscore in @temp do
      @assgn<<Assignment.find(participant.parent_id).name
      @scores<<tscore.score
      @ranges<<tscore.range
      @type<<tscore.object_type
    end
  end
  
  end

end

def viewreviews
  @scoreid = []
  @additionalcomment = []
  if params[:id]=="TeammateReviewResponseMap" || params[:id]=="ParticipantReviewResponseMap"
     @participant_id = Participant.find(:all, :conditions=> ["parent_id=? and user_id=?", Assignment.find_by_name(params[:assgn]).id, params[:user]])
  else
     @participant_id = AssignmentParticipant.find(:all, :conditions => ["parent_id=? and user_id=?", Assignment.find_by_name(params[:assgn]).id, params[:user]])
  end
  for participant in @participant_id do 
    if params[:id]== "TeammateReviewResponseMap" || params[:id]=="ParticipantReviewResponseMap"
      @validresponses = ResponseMap.find(:all, :conditions => ["reviewed_object_id=? and reviewee_id=? and type=?", Assignment.find_by_name(params[:assgn]).id, participant.id, params[:id]] )
    else
      @validresponses = ResponseMap.find(:all, :conditions => ["reviewed_object_id=? and reviewee_id=? and type=?", Assignment.find_by_name(params[:assgn]).id, participant.team, params[:id]] )
    end
    #@validresponses = @validresponses.sort!(&:reviewer_id)
  for validresponse in @validresponses do
    @responseid = Response.find(:all, :conditions=> ["map_id=?", validresponse.id])
  for response in @responseid
    @indivresponses = Score.find(:all, :conditions => ["response_id=?", response.id])  
    @additionalcomment << response.additional_comment
  for responses in @indivresponses do
    @scoreid << responses.id
  end
  end
  end
  end
puts @scoreid.size
end

end
