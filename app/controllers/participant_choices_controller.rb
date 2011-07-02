
class ParticipantChoicesController < ApplicationController
  
  def index
    list
    render :action => 'list'
  end
  
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
  :redirect_to => { :action => :list }
  
  def list
    session[:signup_sheet_id] = params[:id]
    
    @questions = Question.find(:all,
                               :conditions => 'signup_sheet_id = '+params[:id],
    :order => 'id')
    @answers = SignupChoice.find(:all,
                                 :conditions => 'signup_sheet_id = '+params[:id],
    :order => 'question_id')                 
    
    @participant_choices = ParticipantChoice.find_by_sql('select * from participant_choices where user_id='+session[:user].id.to_s+' order by question_id')
    @resubmission_quota = SignupResubmissionQuota.find_by_sql("select * from signup_resubmission_quotas where signup_sheet_id="+params[:id].to_s+" and user_id="+session[:user].id.to_s)
    # get name of the team and participants
    assignment = SignupSheet.find_by_id(session[:signup_sheet_id]).assignment_id.to_s
    # we have to find if we are in any team
    my_team = TeamsUser.find_by_sql("select * from teams_users where user_id="+session[:user].id.to_s+" and team_id in (select id from teams where assignment_id="+assignment+")")
    if my_team != nil && my_team.size > 0
      @team = Team.find_by_sql("select * from teams where assignment_id="+assignment+" and id="+my_team[0].team_id.to_s)
      @team_participants = TeamsUser.find_by_sql("select * from teams_users where team_id = "+my_team[0].team_id.to_s+" and user_id !="+session[:user].id.to_s)
      @participant_list = ""
      @team_participants.each do |participant|
        @participant_list += User.find_by_id(participant.user_id).name+","
      end
    end
  end
  
  def save
    # we have to create a team and its corresponding team members
    # we have to then save the current choice
    deselect = params[:checkQuestion]
    signup = SignupSheet.find_by_id(params[:id])
    if params[:group]!=nil && params[:group][deselect]!= "-1"
      if (signup.team == true)
        createUpdateTeam(params[:team][:name], signup.assignment_id, params[:team][:id], params[:team]) if params[:team][:name] !="" 
        createUpdateTeamUsers(params[:user][:name], params[:team][:id], signup.assignment_id) if params[:team][:name] !="" && params[:user][:name]!="" 
      end
      if params[:group]!=nil
        # save the participant choice
        saveChoice(params[:id], params[:group])
      end
      waitlist(params[:id], params[:priority], params[:checkQuestion], session[:user].id) if params[:priority] != nil
    elsif params[:group]!=nil && params[:group][deselect]== "-1" 
      # remove participant choices and participant answers and delete the team
      if (signup.team == true)
        count = TeamsUser.find(:all, :conditions=>["team_id=?",params[:team][:id]])
        my_team = TeamsUser.find_by_sql("select id from teams_users where user_id="+session[:user].id.to_s+" and team_id="+params[:team][:id])
        if count.size <= 1 
          Team.find(params[:team][:id]).destroy
        end   
        TeamsUser.find(my_team[0].id).destroy        
      end
      # have to reset the resubmission_quota and remove the participant choice
      updateMySubmissionQuota(params[:id], session[:user].id)
      removeMyParticipantChoice(params[:checkQuestion], session[:user].id)
      #removeMyWaitlist(params[:checkQuestion], session[:user].id)
    else
      if (signup.team == true)
        createUpdateTeam(params[:team][:name], signup.assignment_id, params[:team][:id], params[:team]) if params[:team][:name] !="" 
        createUpdateTeamUsers(params[:user][:name], params[:team][:id], signup.assignment_id) if params[:team][:name] !="" && params[:user][:name]!=""
        waitlist(params[:id], params[:priority], params[:checkQuestion], session[:user].id) if params[:priority] != nil
      end
    end
    
  end
  
  def auto_complete_for_user_name
    search = params[:user][:name].to_s
    signup = SignupSheet.find_by_id(session[:signup_sheet_id]).assignment_id.to_s
    @users = User.find_by_sql("select * from users where id !="+session[:user].id.to_s+" and LOWER(name) LIKE '%"+search+"%' and id in (select user_id from participants where user_id not in (select user_id from teams_users where team_id in (select id from teams where assignment_id ="+signup+")) and assignment_id ="+signup+")") unless search.blank?
    render :partial => "members" 
  end
  
  private 
  def createUpdateTeam (team_name , assignment_id, team_id, teamObj)
    ret = false
    check = Team.find(:all, :conditions => ["name =? and assignment_id =?", team_name, assignment_id])
    # for creating a new team since no team exists
    if team_id == ""       
      @team = Team.new()
      @team.name = team_name
      @team.assignment_id = assignment_id
      if (check.length == 0)      
        @team.save
        ret = true
      end
      # for updating an exisiting team
    else
      @team = Team.find(team_id)   
      if (check.length == 0)
        if @team.update_attributes(teamObj)
          ret = true
        end
      elsif (check.length == 1 && check[0].name = team_name)
        ret = true
      end 
    end  
    return ret
  end
  
  def saveChoice(signup_sheet_id, groupObject)
    questions = Question.find(:all,
                              :conditions => 'signup_sheet_id = '+signup_sheet_id,
    :order => 'id')
    questions.each do |qn|
      answers = ParticipantChoice.find_by_sql('select choice_id from participant_choices where user_id='+session[:user].id.to_s+
                                              ' and question_id='+qn.id.to_s)
      if( groupObject[qn.id.to_s].to_s.length > 0 )
        if(answers != nil && answers.length > 0)
          SignupChoice.connection.execute('update signup_choices set slots_occupied=slots_occupied-1
                                                  where id='+answers[0].choice_id.to_s)
          ParticipantChoice.connection.execute('DELETE FROM participant_choices 
                                       WHERE user_id='+session[:user].id.to_s+' AND question_id='+qn.id.to_s)
          # we have to add the person at the head on the waitlist queue for that answer and add him to the signup 
          # if the assignment is team based then we need
          
        end                                                       
        ParticipantChoice.connection.execute('INSERT INTO participant_choices (user_id, choice_id, question_id) 
                                     VALUES ('+session[:user].id.to_s+', '+ groupObject[qn.id.to_s].to_s+', '+qn.id.to_s+')')     
        updateTeamMembersChoice(qn.id, signup_sheet_id)
        SignupChoice.connection.execute('update signup_choices set slots_occupied=slots_occupied+1
                                                  where id='+groupObject[qn.id.to_s].to_s)                                      
      end 
    end
    updateResubmissionQuota(session[:user].id, signup_sheet_id)
  end
  
  def waitlist(signup_id, priorityObject, question_id, user_id)
    waitlistedAnswers = SignupChoice.find(:all,:conditions=>"total_slots = slots_occupied")
    for answer in waitlistedAnswers
      # find whether there exist a waitlist already
      alreadyWaitListed = Waitlist.find(:all, :conditions=>["signup_sheet_id=? and question_id =? and choice_id=? and user_id=?", signup_id, question_id, answer.id, user_id])
      if alreadyWaitListed.size > 0
          # we have to save the in the waitlist table
          # we have to check whether the
        alreadyWaitListed[0].priority = priorityObject[answer.id.to_s] if priorityObject[answer.id.to_s] != ""
        alreadyWaitListed[0].save
      else 
        newWaitList = Waitlist.new()
        newWaitList.question_id = question_id
        newWaitList.signup_sheet_id = signup_id
        newWaitList.choice_id = answer.id
        newWaitList.user_id = user_id
        newWaitList.priority = priorityObject[answer.id.to_s]
        newWaitList.save
      end  
    end
  end
  
  def updateResubmissionQuota (user_id, signup_id)
    resubmission_quota = SignupResubmissionQuota.find_by_sql("select * from signup_resubmission_quotas where user_id ="+user_id.to_s+" and signup_sheet_id="+ signup_id.to_s)
    if (resubmission_quota != nil && resubmission_quota.size ==1)
      resubmission_quota[0].times_done +=1
      if resubmission_quota[0].save
        return true
      end
    else
      resubmission_quota = SignupResubmissionQuota.new()
      resubmission_quota.user_id = session[:user].id
      resubmission_quota.signup_sheet_id = signup_id
      resubmission_quota.times_done = 1
      if resubmission_quota.save
        return true
      end
    end  
  end
  
  def createUpdateTeamUsers (username, team_id, assignment_id)
    if team_id != ""
      restructureTeam(team_id, "")
    end
    username += session[:user].name+','  
    parsed = username.split(",")
    
    parsed.each do |userfromList|
      user = User.find_by_name(userfromList.strip)
      if (team_id == "")
        #   find the newly created team details
        team = Team.find_by_id(getNewTeam)
      else
        team = Team.find_by_id(team_id) #see team members update functionality
      end
      removeUserFromOtherTeam(user.id, team.id, assignment_id)
      @teams_user = TeamsUser.new()
      @teams_user.team_id = team.id
      @teams_user.user_id = user.id
      @teams_user.save! 
    end
  end
  
  def getNewTeam()
    countArr = Team.find_by_sql("select max(id) as id from teams")
    return countArr[0].id
  end
  
  def restructureTeam(team_id, addOn)
    teams = TeamsUser.find_by_sql("select * from teams_users where team_id="+team_id+addOn)
    if teams != nil
      teams.each do |team|
        team.destroy
      end
    end   
  end
  
  def updateTeamMembersChoice(question_id, signup_id)
    assignment = SignupSheet.find_by_id(signup_id).assignment_id.to_s 
    my_team = TeamsUser.find_by_sql("select * from teams_users where user_id !="+session[:user].id.to_s+" and team_id in (select id from teams where assignment_id="+assignment+")")
    my_choice = ParticipantChoice.find_by_sql("select * from participant_choices where id in (select max(id) from participant_choices)")
    for team_members in my_team
      members_choice = ParticipantChoice.new()
      members_choice.question_id = my_choice[0].question_id
      members_choice.choice_id = my_choice[0].choice_id
      members_choice.user_id = team_members.user_id
      members_choice.save
    end
  end
  
  def removeUserFromOtherTeam (user_id, team_id, assignment_id)
    teams = TeamsUser.find_by_sql("select * from teams_users where team_id in (select id from teams where assignment_id ="+assignment_id.to_s+") and user_id ="+user_id.to_s+" and team_id != "+team_id.to_s)
    if teams != nil
      teams.each do |team|
        team.destroy
      end
    end
  end
  
  def updateMySubmissionQuota(signup_id, user_id)
    SignupResubmissionQuota.connection.execute("update signup_resubmission_quotas set times_done=0 where user_id="+user_id.to_s+" and signup_sheet_id="+signup_id.to_s)
  end
  
  def removeMyParticipantChoice(question_id, user_id)
    ParticipantChoice.connection.execute("delete from participant_choices where user_id="+user_id.to_s+" and question_id="+question_id.to_s)
  end
  
end
