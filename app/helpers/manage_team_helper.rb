# This helper contains all functions associated with team management. 
# These include creating a new team, adding a new member to a team etc
# This helper is used by both sign_up_sheet controller and signup controller
module ManageTeamHelper

#Creates a new team. When a user signs up for a topic he/she is in his/her own team
#when other people join the user's team the databse tables are updated to reflect these changes

  def create_team(assignment_id)
    assignment = Assignment.find(assignment_id)   
    teamname = generate_team_name(assignment.name)
    team = AssignmentTeam.create(:name => teamname, :parent_id => assignment.id)
    TeamNode.create(:parent_id => assignment.id, :node_object_id => team.id)
    team
  end
# team names are created as assignment_name_Team<team_number>
  def generate_team_name(teamnameprefix)
    counter = 1
    while (true)
      teamname = teamnameprefix + "_Team#{counter}"
      if (!Team.find_by_name(teamname))
        return teamname
      end
      counter=counter+1
    end
  end
# Adds a user specified bu 'user' object to a team specified by 'team_id'
  def create_team_users(user, team_id)
#if user does not exist flash message
    if !user
      urlCreate = url_for :controller => 'users', :action => 'new'
      flash[:error] = "\"#{params[:user][:name].strip}\" is not defined. Please <a href=\"#{urlCreate}\">create</a> this user before continuing."
    end
#find the team with 'team_id' form database and add new user to team
    team = Team.find(team_id)
    team.add_member(user)
  end
#check if the user specified by 'user' already belongs to team specified by 'team_id'
  def has_user(user, team_id)
    if TeamsUser.find_by_team_id_and_user_id(team_id, user.id)
      return true
    else
      return false
    end
  end

end
