class ParticipantsController < ApplicationController
  autocomplete :user, :name

  def action_allowed?
    if params[:action] == 'change_handle' or params[:action] == 'update_duties'
      ['Instructor',
       'Teaching Assistant',
       'Administrator',
       'Super-Administrator',
       'Student'].include? current_role_name
    else
      ['Instructor',
       'Teaching Assistant',
       'Administrator',
       'Super-Administrator'].include? current_role_name
    end
  end

  def list
    if Participant::PARTICIPANT_TYPES.include? params[:model]
      @root_node = Object.const_get(params[:model] + "Node").find_by_node_object_id(params[:id])
      @parent = Object.const_get(params[:model]).find(params[:id])
    end
    begin
      @participants = @parent.participants
      @model = params[:model]
      # E726 Fall2012 Changes Begin
      @authorization = params[:authorization]
      # E726 Fall2012 Changes End
    rescue
      flash[:error] = $!
    end
  end

  # OSS_808 change 28th oct
  # required for sending emails
  def email_sent
    DelayedMailer.deliver_mail("recipient.address@example.com")
  end

  def add
    curr_object = Object.const_get(params[:model]).find(params[:id]) if Participant::PARTICIPANT_TYPES.include? params[:model]
    begin
      permissions = Participant.get_permissions(params[:authorization])
      can_submit = permissions[:can_submit]
      can_review = permissions[:can_review]
      can_take_quiz = permissions[:can_take_quiz]
      curr_object.add_participant(params[:user][:name], can_submit, can_review, can_take_quiz)
      user = User.find_by_name(params[:user][:name])
      @participant = curr_object.participants.find_by_user_id(user.id)
      undo_link("The user \"#{params[:user][:name]}\" has successfully been added.")
    rescue
      url_new_user = url_for controller: 'users', action: 'new'
      flash[:error] = "The user #{params[:user][:name]} does not exist or has already been added.</a>"
    end
    redirect_to action: 'list', id: curr_object.id, model: params[:model], authorization: params[:authorization]
  end

  def update_authorizations
    permissions = Participant.get_permissions(params[:authorization])
    can_submit = permissions[:can_submit]
    can_review = permissions[:can_review]
    can_take_quiz = permissions[:can_take_quiz]

    participant = Participant.find(params[:id])
    parent_id = participant.parent_id
    participant.update_attributes(can_submit: can_submit, can_review: can_review, can_take_quiz: can_take_quiz)

    redirect_to action: 'list', id: parent_id, model: participant.class.to_s.gsub("Participant", "")
  end

  # duties: manager, designer, programmer, tester
  def update_duties
    participant = Participant.find(params[:student_id])
    participant.update_attributes(duty: params[:duty])
    redirect_to controller: 'student_teams', action: 'view', student_id: participant.id
  end

  def destroy
    participant = Participant.find(params[:id])
    name = participant.user.name
    parent_id = participant.parent_id
    begin
      @participant = participant
      participant.delete(params[:force])
      flash[:note] = undo_link("The user \"#{name}\" has been successfully removed as a participant.")
    rescue => error
      url_yes = url_for action: 'delete', id: params[:id], force: 1
      url_show = url_for action: 'delete_display', id: params[:id], model: participant.class.to_s.gsub("Participant", "")
      url_no = url_for action: 'list', id: parent_id, model: participant.class.to_s.gsub("Participant", "")
      flash[:error] = "The delete action failed: At least one (1) review mapping or team membership exist for this participant. <br/><a href='#{url_yes}'>Delete this participant</a>&nbsp;|&nbsp;<a href='#{url_show}'>Show me the associated items</a>|&nbsp;<a href='#{url_no}'>Do nothing</a><BR/>"
    end
    redirect_to action: 'list', id: parent_id, model: participant.class.to_s.gsub("Participant", "")
  end

  def delete_display
    @participant = Participant.find(params[:id])
    @model = params[:model]
  end

  def delete_items
    participant = Participant.find(params[:id])
    maps = params[:ResponseMap]
    teamsusers = params[:TeamsUser]

    unless maps.nil?
      maps.each do |rmap_id|
        begin
          ResponseMap.find(rmap_id[0].to_i).delete(true)
        rescue
        end
      end
    end

    unless teamsusers.nil?
      teamsusers.each do |tuser_id|
        begin
          TeamsUser.find(tuser_id[0].to_i).delete
        rescue
        end
      end
    end

    redirect_to action: 'delete', id: participant.id, method: :post
  end

  # Copies existing participants from a course down to an assignment
  def inherit
    assignment = Assignment.find(params[:id])
    course = assignment.course
    @copied_participants = []

    if course
      participants = course.participants
      if !participants.empty?
        participants.each do |participant|
          new_participant = participant.copy(params[:id])

          @copied_participants.push new_participant if new_participant
        end

        # Only display undo link if copies of participants are created
        if !@copied_participants.empty?
          undo_link("The participants from \"#{course.name}\" have been successfully copied to this assignment. ")
        else
          flash[:note] = 'All course participants are already in this assignment'
        end

      else
        flash[:note] = "No participants were found to inherit this assignment."
      end
    else
      flash[:error] = "No course was found for this assignment."
    end

    redirect_to controller: 'participants', action: 'list', id: assignment.id, model: 'Assignment'
  end

  def bequeath_all
    @copied_participants = []
    assignment = Assignment.find(params[:id])
    if assignment.course
      course = assignment.course
      assignment.participants.each do |participant|
        new_participant = participant.copy(course.id)

        @copied_participants.push new_participant if new_participant
      end
      # only display undo link if copies of participants are created
      if !@copied_participants.empty?
        undo_link("All participants were successfully copied to \"#{course.name}\". ")
      else
        flash[:note] = 'All assignment participants are already part of the course'
      end

      # flash[:note] = "All participants were successfully copied to \""+course.name+"\""
    else
      flash[:error] = "This assignment is not associated with a course."
    end

    redirect_to controller: 'participants', action: 'list', id: assignment.id, model: 'Assignment'
  end

  # Allow participant to change handle for this assignment
  # If the participant parameters are available, update the participant
  # and redirect to the view_actions page
  def change_handle
    @participant = AssignmentParticipant.find(params[:id])
    return unless current_user_id?(@participant.user_id)

    unless params[:participant].nil?
      if !AssignmentParticipant.where(parent_id: @participant.parent_id, handle: params[:participant][:handle]).empty?
        flash[:error] = "<b>The handle #{params[:participant][:handle]}</b> is already in use for this assignment. Please select a different one."
        redirect_to controller: 'participants', action: 'change_handle', id: @participant
      else
        @participant.update_attributes(participant_params)
        redirect_to controller: 'student_task', action: 'view', id: @participant
      end
    end
  end

  def delete_assignment_participant
    contributor = AssignmentParticipant.find(params[:id])
    name = contributor.name
    assignment_id = contributor.assignment
    begin
        contributor.destroy
        flash[:note] = "\"#{name}\" is no longer a participant in this assignment."
      rescue
        flash[:error] = "\"#{name}\" was not removed from this assignment. Please ensure that \"#{name}\" is not a reviewer or metareviewer and try again."
      end
    redirect_to controller: 'review_mapping', action: 'list_mappings', id: assignment_id
  end

  # Seems like this function is similar to the above function> we are not quite sure what publishing rights mean. Seems like
  # the values for the last column in http://expertiza.ncsu.edu/student_task/list are sourced from here
  def view_publishing_rights
    # Get the assignment ID from the params
    assignment_id = params[:id]

    # Get the assignment object for the above ID and set the @assignment_name object for the view
    assignment = Assignment.find(assignment_id)
    @assignment_name = assignment.name

    # Initially set to false, will be true if the assignment has any topics
    @has_topics = false

    # Attribute that contains the list of the teams and their info related to this assignment
    @teams_info = []

    # Get all the teams that work on the assignment with ID assignment_id
    teams = Team.find_by_sql(["select * from teams where parent_id = ?", assignment_id])

    # For each of the teams, do
    teams.each do |team|
      team_info = {}
      # Set the team name
      team_info[:name] = team.name
      # List that hold the details of the users in the team
      users = []
      # For each of the users, do
      team.users.each do |team_user|
        # Append the user info to the users list
        users.append(get_user_info(team_user, assignment))
      end
      # Append the users list to the team_info object
      team_info[:users] = users

      # Get the signup topics for the assignment
      @has_topics = get_signup_topics_for_assignment(assignment_id, team_info, team.id)

      # Choose only those teams that have signed up for topics
      team_without_topic = !SignedUpTeam.where(["team_id = ?", team.id]).any?
      next if @has_topics && team_without_topic

      # Append the hashmap to the list of hashmaps
      @teams_info.append(team_info)
    end
    @teams_info = @teams_info.sort_by {|hashmap| [hashmap[:topic_id] ? 0 : 1, hashmap[:topic_id] || 0] }
  end

  private

  def participant_params
    params.require(:participant).permit(:can_submit, :can_review, :user_id, :parent_id, :submitted_at, :permission_granted, :penalty_accumulated, :grade, :type, :handle, :time_stamp, :digital_signature, :duty, :can_take_quiz)
  end

  # Get the user info from the team user
  def get_user_info(team_user, assignment)
    user = {}
    # Set user's name
    user[:name] = team_user.name
    # Set user's fullname
    user[:fullname] = team_user.fullname

    # Get the permissions straight
    permissionGranted = false
    hasSignature = false
    signatureValid = false
    assignment.participants.each do |participant|
      if team_user.id == participant.user.id
        permissionGranted = participant.permission_granted?
      end
    end
    # If permission is granted, set the publisting rights string
    user[:pub_rights] = if permissionGranted
                          "Granted"
                        else
                          "Denied"
                        end
    user[:verified] = permissionGranted && hasSignature && signatureValid
    user
  end

  # Get the signup topics for the assignment
  def get_signup_topics_for_assignment(assignment_id, team_info, teamId)
    # Get the signup topics, if any for this assignment
    signup_topics = SignUpTopic.where(['assignment_id = ?', assignment_id])
    if signup_topics.any?
      # Set this attribute to true
      has_topics = true
      # Iterate through the list of signup_topics
      signup_topics.each do |signup_topic|
        # For each team that signed up for this topic, do
        signup_topic.signed_up_teams.each do |signed_up_team|
          # If this team's id == current team's id, set the corresponding values
          if signed_up_team.team_id == teamId
            team_info[:topic_name] = signup_topic.topic_name
            team_info[:topic_id] = signup_topic.topic_identifier.to_i
          end
        end
      end
    end
    has_topics
  end
end
