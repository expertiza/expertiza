# Controller for managing team participants in an educational application.
class TeamsParticipantsController < ApplicationController
  include AuthorizationHelper  # Includes methods to check user authorization levels.

  # Decides whether the current user's action is allowed based on their role.
  def action_allowed?
    # Allows updating duties if the user is a student, otherwise requires TA or higher privileges for other actions.
    if %w[update_duties].include? params[:action]
      current_user_has_student_privileges?
    else
      current_user_has_ta_privileges?
    end
  end

  # Autocomplete action for user name input in forms related to teams.
  def auto_complete_for_user_name
    team = Team.find(session[:team_id])  # Finds the current team from session.
    @users = team.get_possible_team_members(params[:user][:name])  # Fetches users matching the input for autocomplete.
    render inline: "<%= auto_complete_result @users, 'name' %>", layout: false  # Renders the autocomplete response.
  end

  # Updates the duty for a team participant and redirects to the team view.
  def update_duties
    team_user = TeamsParticipant.find(params[:teams_user_id])  # Locates the specific team participant.
    team_user.update_attribute(:duty_id, params[:teams_user]['duty_id'])  # Sets the new duty ID.
    redirect_to controller: 'student_teams', action: 'view', student_id: params[:participant_id]  # Redirects to student team view.
  end

  # Lists participants in a team.
  def list
    @team = Team.find(params[:id])  # Retrieves the team based on the ID provided.
    @assignment = Assignment.find(@team.parent_id)  # Retrieves the assignment linked to the team.
    @teams_participants = TeamsParticipant.page(params[:page]).per_page(10).where(['team_id = ?', params[:id]])  # Paginates the participants of the team.
  end

  # Prepares for the creation of a new team participant by initializing required variables.
  def new
    @team = Team.find(params[:id])  # Retrieves the team for which a new participant is to be added.
  end

  # Creates a new team participant entry.
  # def create
  #   user = User.find_by(name: params[:user][:name].strip)  # Attempts to find an existing user by name.
  #   unless user
  #     urlCreate = url_for(controller: 'users', action: 'new')  # Prepares the URL for user creation.
  #     flash[:error] = "\"#{params[:user][:name].strip}\" is not defined. Please <a href=\"#{urlCreate}\">create</a> this user before continuing."
  #     return  # Exits the method early if the user does not exist.
  #   end

  #   team = Team.find(params[:id])  # Finds the team to add the user to.
  #   unless user.nil?
  #     if team.is_a?(AssignmentTeam)  # Differentiates behavior based on whether the team is for an assignment.
  #       assignment = Assignment.find(team.parent_id)  # Retrieves the associated assignment.
  #       participant = AssignmentParticipant.find_by(user_id: user.id, parent_id: assignment.id)  # Finds or initializes the participant.
  #       if assignment.participant_on_team?(participant)  # Checks if the participant is already on a team.
  #         flash[:error] = "This user is already assigned to a team for this assignment"
  #         redirect_back fallback_location: root_path
  #         return
  #       end
  #       if participant.nil?  # Checks if the participant does not exist.
  #         urlAssignmentParticipantList = url_for(controller: 'participants', action: 'list', id: assignment.id, model: 'Assignment', authorization: 'participant')
  #         flash[:error] = "\"#{user.name}\" is not a participant of the current assignment. Please <a href=\"#{urlAssignmentParticipantList}\">add</a> this user before continuing."
  #       else
  #         begin
  #           add_member_return = team.add_participant_to_team(participant, team.parent_id)  # Tries to add the participant to the team.
  #         rescue  # Handles exceptions if adding the participant fails (e.g., already a member).
  #           flash[:error] = "The user #{user.name} is already a member of the team #{team.name}"
  #           redirect_back fallback_location: root_path
  #           return
  #         end
  #         flash[:error] = 'This team already has the maximum number of members.' if add_member_return == false  # Checks if the team is full.
  #       end
  #     else  # Handles the case for course teams similarly.
  #       course = Course.find(team.parent_id)
  #       participant = CourseParticipant.find_by(user_id: user.id, parent_id: course.id)
  #       if course.participant_on_team?(participant)
  #         flash[:error] = "This user is already assigned to a team for this course"
  #         redirect_back fallback_location: root_path
  #         return
  #       end
  #       if CourseParticipant.find_by(user_id: user.id, parent_id: course.id).nil?
  #         urlCourseParticipantList = url_for(controller: 'participants', action: 'list', id: course.id, model: 'Course', authorization: 'participant')
  #         flash[:error] = "\"#{user.name}\" is not a participant of the current course. Please <a href=\"#{urlCourseParticipantList}\">add</a> this user before continuing."
  #       else
  #         begin
  #           add_member_return = team.add_participant_to_team(participant, team.parent_id)
  #         rescue
  #           flash[:error] = "The user #{user.name} is already a member of the team #{team.name}"
  #           redirect_back fallback_location: root_path
  #           return
  #         end
  #         flash[:error] = 'This team already has the maximum number of members.' if add_member_return == false
  #         if add_member_return
  #           @teams_participant = TeamsParticipant.last  # Captures the last added participant for confirmation.
  #           undo_link("The team user \"#{user.name}\" has been successfully added to \"#{team.name}\".")  # Provides an undo link with a success message.
  #         end
  #       end
  #     end
  #   end

  #   redirect_to controller: 'teams', action: 'list', id: team.parent_id  # Redirects to the list of teams.
  # end

  # Starts the creation process for adding a user to a team
def create
  user = validate_user(params[:user][:name])  # Validate and find user
  return unless user  # Exit if user validation fails

  team = Team.find(params[:id])  # Finds the team to add the user to
  process_team_addition(user, team)  # Processes addition based on team type

  redirect_to controller: 'teams', action: 'list', id: team.parent_id  # Redirects to the list of teams
end

# Validates the existence of a user and handles error messaging
def validate_user(user_name)
  user = User.find_by(name: user_name.strip)  # Attempts to find an existing user by name
  unless user
    flash[:error] = "\"#{user_name.strip}\" is not defined. Please create this user before continuing."
    redirect_back(fallback_location: root_path)  # Redirects back if the user does not exist
    return nil
  end
  user
end

# Processes the addition of a user to the team, handling different types of teams
def process_team_addition(user, team)
  participant = find_or_create_participant(user, team)
  return unless participant  # Return if participant validation fails

  add_member_to_team(team, participant, user)  # Adds member to the team and handles errors
end

# Finds or initializes the participant based on team type and ensures they are not already part of a team
def find_or_create_participant(user, team)
  model_class = team.is_a?(AssignmentTeam) ? AssignmentParticipant : CourseParticipant
  participant = model_class.find_by(user_id: user.id, parent_id: team.parent_id)

  if participant && team.participant_on_team?(participant)
    flash[:error] = "This user is already assigned to a team for this #{model_class.name.gsub('Participant','').downcase}"
    redirect_back(fallback_location: root_path)
    return nil
  end

  unless participant
    flash[:error] = "\"#{user.name}\" is not a participant of the current #{model_class.name.gsub('Participant','').downcase}. Please add this user before continuing."
    redirect_back(fallback_location: root_path)
    return nil
  end
 
  participant
end

# Attempts to add a participant to a team and handles potential errors
def add_member_to_team(team, participant, user)
  begin
    add_member_return = team.add_participant_to_team(participant, team.parent_id)
    if add_member_return == false
      flash[:error] = 'This team already has the maximum number of members.'
    else
      flash[:notice] = "The user \"#{user.name}\" has been successfully added to \"#{team.name}\"."
    end
  rescue => e  # Catches any exceptions and logs them
    flash[:error] = "Failed to add user #{user.name} to the team #{team.name}: #{e.message}"
  end
end


  # Deletes a specific participant from a team.
  def delete
    @teams_participant = TeamsParticipant.find(params[:id])  # Finds the participant to be deleted.
    parent_id = Team.find(@teams_participant.team_id).parent_id  # Identifies the parent ID for redirection.
    participant = Participant.find_by(id: @teams_participant.participant_id)
    @user = User.find(participant.user_id)  # Finds the user linked to the participant.
    @teams_participant.destroy  # Destroys the participant record.
    undo_link("The team user \"#{@user.name}\" has been successfully removed. ")  # Provides a method to undo the deletion.
    redirect_to controller: 'teams', action: 'list', id: parent_id  # Redirects to the teams list.
  end

  # Bulk deletion of selected team participants.
  def delete_selected
    params[:item].each do |item_id|
      team_user = TeamsParticipant.find(item_id)  # Iterates through each selected participant.
      team_user.destroy  # Destroys the participant record.
    end

    redirect_to action: 'list', id: params[:id]  # Redirects to the team list after deletion.
  end
end
