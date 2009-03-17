class StudentTeamController < ApplicationController
  auto_complete_for :user, :name
   
  def view
    @student = AssignmentParticipant.find(params[:id])
    @teams = AssignmentTeam.find_all_by_parent_id(@student.parent_id)    
    for team in @teams
      @teamuser = TeamsUser.find(:first, :conditions => ['team_id = ? and user_id = ?', team.id, @student.user_id])
      if @teamuser != nil
        @team_id = @teamuser.team_id
      end
    end
    
    @team_members = TeamsUser.find(:all, :conditions => ['team_id = ?', @team_id])
    @send_invs = Invitation.find(:all, :conditions => ['from_id = ? and assignment_id = ?', @student.user_id, @student.parent_id])
    @received_invs = Invitation.find(:all, :conditions => ['to_id = ? and assignment_id = ? and reply_status = "W"', @student.user_id, @student.parent_id])
  end
  
  def new
    @student = AssignmentParticipant.find(params[:id])
    @team = Team.new 
  end
  
  def create
    @student = AssignmentParticipant.find(params[:id])
    check = AssignmentTeam.find(:all, :conditions => ["name =? and parent_id =?", params[:team][:name], @student.parent_id])        
    @team = AssignmentTeam.new(params[:team])
    @team.parent_id = @student.parent_id    
    #check if the team name is in use
    if (check.length == 0)      
      @team.save
      parent = AssignmentNode.find_by_node_object_id(@student.parent_id)
      TeamNode.create(:parent_id => parent.id, :node_object_id => @team.id)
      user = User.find(@student.user_id)
      @team.add_member(user)      
      redirect_to :controller => 'student_team', :action => 'view' , :id=> @student.id
    else
      flash[:notice] = 'Team name is already in use.'
      redirect_to :controller => 'student_team', :action => 'view' , :id=> @student.id
    end 
  end
  
  def edit 
    @team = AssignmentTeam.find_by_id(params[:team_id])
    @student = AssignmentParticipant.find(params[:student_id])
  end
  
  def update
    @team = AssignmentTeam.find_by_id(params[:team_id])
    check = AssignmentTeam.find(:all, :conditions => ["name =? and parent_id =?", params[:team][:name], @team.parent_id])    
    if (check.length == 0)
       if @team.update_attributes(params[:team])
          redirect_to :controller => 'student_assignment', :action => 'view_team', :id => params[:student_id]
       end
    elsif (check.length == 1 && (check[0].name <=> @team.name) == 0)
      redirect_to :controller => 'student_assignment', :action => 'view_team', :id => params[:student_id]
    else
      flash[:notice] = 'Team name is already in use.'
      redirect_to :controller =>'student_team', :action => 'edit', :team_id =>params[:team_id], :student_id => params[:student_id]
    end 
  end
  
  def leave
    @student = AssignmentParticipant.find(params[:student_id])
    #remove the entry from teams_users
    user = TeamsUser.find(:first, :conditions =>["team_id =? and user_id =?", params[:team_id], @student.user_id])
    if user
      user.destroy
    end
    
    #if your old team does not have any members, delete the entry for the team
    other_members = TeamsUser.find(:all, :conditions => ['team_id = ?', params[:team_id]])
    if other_members.length == 0
      old_team = AssignmentTeam.find(:first, :conditions => ['id = ?', params[:team_id]])
      if old_team != nil
        old_team.destroy
      end
    end
    
    #remove all the sent invitations
    old_invs = Invitation.find(:all, :conditions => ['from_id = ? and assignment_id = ?', @student.user_id, @student.parent_id])
    for old_inv in old_invs
      old_inv.destroy
    end
    redirect_to :controller => 'student_team', :action => 'view' , :id => @student.id
  end
  
  def review
    @assignment = Assignment.find_by_id(params[:assignment_id])
    redirect_to :controller =>'questionnaire', :action => 'view_questionnaire', :id => @assignment.teammate_review_questionnaire_id
  end
end
