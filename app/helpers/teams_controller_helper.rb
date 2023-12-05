# app/helpers/teams_controller_helper.rb
module TeamsControllerHelper
	def create_random_teams(parent)
	  Team.randomize_all_by_parent(parent, session[:team_type], params[:team_size].to_i)
	  undo_link('Random teams have been successfully created.')
	end
  
	def log_team_creation
	  ExpertizaLogger.info LoggerMessage.new(controller_name, '', 'Random teams have been successfully created', request)
	end
  
	def redirect_to_team_list(parent_id)
	  redirect_to action: 'list', id: parent_id
	end
  
	def create_team_manually(parent)
	  begin
		create_team(parent)
		create_team_node(parent)
		set_undo_link_for_team_creation
		redirect_to_team_list(parent.id)
	  rescue TeamExistsError
		handle_team_exists_error(parent.id)
	  end
	end
  
	def create_team(parent)
	  Team.check_for_existing(parent, params[:team][:name], session[:team_type])
	  @team = Object.const_get(session[:team_type] + 'Team').create_team_manually(name: params[:team][:name], parent_id: parent.id)
	end
  
	def create_team_node(parent)
	  TeamNode.create_team_manually(parent_id: parent.id, node_object_id: @team.id)
	end
  
	def set_undo_link_for_team_creation
	  undo_link("The team \"#{@team.name}\" has been successfully created.")
	end
  
	def handle_team_exists_error(parent_id)
	  flash[:error] = $ERROR_INFO
	  redirect_to action: 'new', id: parent_id
	end
  
	def update_team_name(parent, new_name)
	  Team.check_for_existing(parent, new_name, session[:team_type])
	  @team.name = new_name
	  @team.save
	end
  
	def set_success_flash_for_update
	  flash[:success] = "The team \"#{@team.name}\" has been successfully updated."
	end
  
	def undo_link_for_update
	  undo_link('')
	end
  
	def handle_team_exists_error_for_update(team_id)
	  flash[:error] = $ERROR_INFO
	  redirect_to action: 'edit', id: team_id
	end
  
	def delete_teams(child_node_ids)
	  Team.where(id: child_node_ids).destroy_all
	end
  
	def handle_team_sign_ups(team)
	  signed_up_team = SignedUpTeam.where(team_id: team.id).first
	  return unless signed_up_team && !signed_up_team.is_waitlisted
  
	  topic_id = signed_up_team.topic_id
	  next_wait_listed_team = SignedUpTeam.where(topic_id: topic_id, is_waitlisted: true).first
	  SignUpTopic.assign_to_first_waiting_team(next_wait_listed_team) if next_wait_listed_team
	end
  
	def delete_associated_records(team)
	  signed_up_teams = SignedUpTeam.where(team_id: team.id)
	  teams_users = TeamsUser.where(team_id: team.id)
  
	  signed_up_teams.destroy_all if signed_up_teams.present?
	  teams_users.destroy_all if teams_users.present?
	  team.destroy
	end
  
	def set_undo_link_for_deletion(team_name)
	  undo_link("The team \"#{team_name}\" has been successfully deleted.")
	end
  
	def copy_teams_to_course(teams, course)
	  Team.copy_content(teams, course)
	  set_flash_note("#{teams.length} teams were successfully copied to \"#{course.name}\"")
	end
  
	def copy_teams_to_assignment(teams, assignment)
	  Team.copy_content(teams, assignment)
	  set_flash_note("#{teams.length} teams were successfully copied to \"#{assignment.name}\"")
	end
  
	def set_flash_error(message)
	  flash[:error] = message
	end
  
	def set_flash_note(message)
	  flash[:note] = message
	end
  end