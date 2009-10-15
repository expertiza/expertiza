class TeamController < ApplicationController
 auto_complete_for :user, :name  

   ############## These methods created by mahesh############
 def And(number1, number2)
   #produces bitwise and of two integers
   return number1&number2
 end
 
 def score(team)
   #for each student in team 
   #result += And(studnet, nextstudnet)
   #dec2bin(result)
   #return sum of 1's in dec2bin(result) 
 end
 
 def min(a,b)
   if a<b
     return a   
   else
     return b
   end
 end
 
def create_teams_view
 @parent = Object.const_get(session[:team_type]).find(params[:id])
 
end

def delete_all
  
#  parent = Object.const_get(session[:team_type]).find(params[:id])
#  redirect_to :action => 'list' , :id => parent.id
  
#  participants = Participant.find_all(["parent_id=?",parent.id])
#  no_of_teams = (participants.length)/(parent.team_count)
#  diff = (participants.length)%(parent.team_count)
  

    #no_of_teams ++

  
#
#   for i in 1..no_of_teams
#   team = Team.find_by_name("Team #{i}")
 #  team.delete
#   end

  parent = Object.const_get(session[:team_type]).find(params[:id])  
  teams = Team.find_all(["parent_id=?",parent.id])
  
  for team in teams
    team.delete
  end
redirect_to :action => 'list', :id => parent.id

end



def randomize_teams
  
   parent = Object.const_get(session[:team_type]).find(params[:id])  
   participants = Participant.find_all(["parent_id=?",parent.id])
   
   participants = participants.sort{rand(3) - 1 }
   
      
   #participants = Participant.find_by_sql("SELECT user_id from participants where parent_id = ", parent.id)
    for participant in participants 
      puts participant.user_id
      user = User.find_by_id(participant.user_id)
      puts user.name
    end
  
   puts "***********" 
   puts participants.length
   puts parent.team_count
   
   no_of_teams = (participants.length)/(parent.team_count)
   diff = (participants.length)%(parent.team_count)
   
   i=0
   j=0
   k=0
   
   
         
  for i in 1..no_of_teams
      #formteam("Team"+ i+1)
      #puts i
    #team = Object.const_get(session[:team_type]+'Team').create(:name => "#{parent.name} Team #{i}", :parent_id => parent.id)
   begin
     check_for_existing_team_name(parent,"Team #{i}")
     
   rescue TeamExistsError
   team = Team.find_by_name("Team #{i}")
   team.delete
     
   end
     team = Object.const_get(session[:team_type]+'Team').create(:name => "Team #{i}", :parent_id => parent.id)
     TeamNode.create(:parent_id => parent.id, :node_object_id => team.id)
 
     
    j=i*parent.team_count
    
    for k in 1..parent.team_count
    #for k in 0..(parent.team_count -1)
    user = User.find_by_id(participants[j-k].user_id)
    team.add_member(user)
    #puts parent.team_count
    end
    #puts parent.team_count
  end

    
  if diff != 0
    begin
     check_for_existing_team_name(parent,"Team #{no_of_teams+1}")
     
   rescue TeamExistsError
   team = Team.find_by_name("Team #{no_of_teams+1}")
   team.delete
     
   end
    
  team = Object.const_get(session[:team_type]+'Team').create(:name => "Team #{no_of_teams+1}", :parent_id => parent.id)
  TeamNode.create(:parent_id => parent.id, :node_object_id => team.id)
  
  for indx in 1..diff
    user = User.find_by_id(participants[participants.length-indx].user_id)
    team.add_member(user)
  end
    
    
  end
 
 #for each member of the user-assignment table create random teams
 # and add them to the database 
  
end




def create_teams
   parent = Object.const_get(session[:team_type]).find(params[:id])
      
   #call randomize
   randomize_teams
   #teams = Team.find_all(["parent_id=?",parent.id])
   #for tm in teams
    # puts "##########"
     #puts tm.id
   #end
   
   #for tm in teams
   #team_users = TeamsUser.find_all(["team_id=?",tm.id])
   #puts "###############"
   #puts team_users.user_id
   #end
      
   
  #The actual team maker algorithm
  #for i in 1 .. 20
    # for each random team A in teamset
        #for each random team B in teamset - {team A}
            #for each studentA in team A
                #for each studentB in team B
                    #oldscore = min(score(teamA),score(teamB))
                    #swap studnetA and studentB
                    #newscore = min(score(teamA),score(teamB))
                    #if newscore < Thresholdscore
                      #revert
                    #end if
                #end
            #end
        #end
    #end  
  #i++
  #end

  #if all team scores >= Thresholdscore
  #add each student into the table
  #add each team to the table 
   
  redirect_to :action => 'list', :id => parent.id
 end


##############                                       ############
 def list
   if params[:type]
    session[:team_type] = params[:type]
   end
   @root_node = Object.const_get(session[:team_type]+"Node").find_by_node_object_id(params[:id])   
   @child_nodes = @root_node.get_teams()
 end
 
 def new
   @parent = Object.const_get(session[:team_type]).find(params[:id])   
 end
 
 def create
   parent = Object.const_get(session[:team_type]).find(params[:id])
   begin
    check_for_existing_team_name(parent,params[:team][:name])
    team = Object.const_get(session[:team_type]+'Team').create(:name => params[:team][:name], :parent_id => parent.id)
    TeamNode.create(:parent_id => parent.id, :node_object_id => team.id)
    redirect_to :action => 'list', :id => parent.id
   rescue TeamExistsError
    flash[:error] = $! 
    redirect_to :action => 'new', :id => parent.id
   end
 end
 
 def update  
   team = Team.find(params[:id])
   parent = Object.const_get(session[:team_type]).find(team.parent_id)
   begin
    check_for_existing_team_name(parent,params[:team][:name])
    team.name = params[:team][:name]
    team.save
    redirect_to :action => 'list', :id => parent.id
   rescue TeamExistsError
    flash[:error] = $! 
    redirect_to :action => 'edit', :id => team.id
   end   
 end
 
 def edit
   @team = Team.find(params[:id])
 end
 
 def delete   
   team = Team.find(params[:id])
   course = Object.const_get(session[:team_type]).find(team.parent_id)
   team.delete
   redirect_to :action => 'list', :id => course.id
 end
 
 # Copies existing teams from a course down to an assignment
 # The team and team members are all copied.  
 def inherit
   assignment = Assignment.find(params[:id])
   if assignment.course_id > 0
    course = Course.find(assignment.course_id)
    teams = course.get_teams
    if teams.length > 0 
      teams.each{
        |team|
        team.copy(assignment.id)
      }
    else
      flash[:note] = "No teams were found to inherit."
    end
   else
     flash[:error] = "No course was found for this assignment."
   end
   redirect_to :controller => 'team', :action => 'list', :id => assignment.id   
 end
 
 # Copies existing teams from an assignment up to a course
 # The team and team members are all copied. 
 def bequeath
   team = AssignmentTeam.find(params[:id])
   assignment = Assignment.find(team.parent_id)
   if assignment.course_id
      course = Course.find(assignment.course_id)
      team.copy(course.id)
      flash[:note] = "\""+team.name+"\" was successfully copied to \""+course.name+"\""
   else
      flash[:error] = "This assignment is not #{url_for(:controller => 'assignment', :action => 'assign', :id => assignment.id)} with a course."
   end      
   redirect_to :controller => 'team', :action => 'list', :id => assignment.id
 end
 
 protected
 
 def check_for_existing_team_name(parent,name)    
    list = Object.const_get(session[:team_type]+'Team').find(:all, :conditions => ['parent_id = ? and name = ?',parent.id,name])
    if list.length > 0     
      raise TeamExistsError, 'Team name, "'+name+'", is already in use.'
    end
 end

 
end