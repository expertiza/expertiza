class StudentTeamsController < ApplicationController
  autocomplete :user, :name

  def team
    @team ||= AssignmentTeam.find params[:team_id]
  end

  attr_writer :team

  def student
    @student ||= AssignmentParticipant.find(params[:student_id])
  end

  attr_writer :student

  before_action :team, only: [:edit, :update]
  before_action :student, only: [:view, :update, :edit, :create, :remove_participant]

  def action_allowed?
    # note, this code replaces the following line that cannot be called before action allowed?
    if ['Instructor',
        'Teaching Assistant',
        'Administrator',
        'Super-Administrator',
        'Student'].include? current_role_name and ((%w(view).include? action_name) ? are_needed_authorizations_present? : true)
      # make sure the student is the owner if they are trying to create it
      return current_user_id? student.user_id if %w(create).include? action_name
      # make sure the student belongs to the group before allowed them to try and edit or update
      return team.get_participants.map(&:user_id).include? current_user.id if %w(edit update).include? action_name
      return true
    else
      return false
    end
  end

  def view
    # View will check if send_invs and recieved_invs are set before showing
    # only the owner should be able to see those.
    return unless current_user_id? student.user_id

    @send_invs = Invitation.where from_id: student.user.id, assignment_id: student.assignment.id
    @received_invs = Invitation.where to_id: student.user.id, assignment_id: student.assignment.id, reply_status: 'W'
    # Get the current due dates
    @student.assignment.due_dates.each do |due_date|
      if due_date.due_at > Time.now
        @current_due_date = due_date
        break
      end
    end

    current_team = @student.team

    @users_on_waiting_list = if @student.assignment.has_topics? && current_team && current_team.topic
                               SignUpTopic.find(current_team.topic).users_on_waiting_list
                             end

    @teammate_review_allowed = true if @student.assignment.find_current_stage == 'Finished' || @current_due_date && (@current_due_date.teammate_review_allowed_id == 3 || @current_due_date.teammate_review_allowed_id == 2) # late(2) or yes(3)
  end

  def create
    existing_assignments = AssignmentTeam.where name: params[:team][:name], parent_id: student.parent_id
    # check if the team name is in use
    if existing_assignments.empty?
      if params[:team][:name].nil? || params[:team][:name].empty?
        flash[:notice] = 'The team name is empty.'
        redirect_to view_student_teams_path student_id: student.id
        return
      end
      team = AssignmentTeam.new(name: params[:team][:name], parent_id: student.parent_id)
      team.save
      parent = AssignmentNode.find_by_node_object_id student.parent_id
      TeamNode.create parent_id: parent.id, node_object_id: team.id
      user = User.find student.user_id
      team.add_member user, team.parent_id
      team_created_successfully(team)
      redirect_to view_student_teams_path student_id: student.id

    else
      flash[:notice] = 'That team name is already in use.'
      redirect_to view_student_teams_path student_id: student.id
    end
  end

  def edit
  end

  def update
    matching_teams = AssignmentTeam.where name: params[:team][:name], parent_id: team.parent_id
    if matching_teams.length.zero?
      if team.update_attribute('name', params[:team][:name])
        team_created_successfully

        redirect_to view_student_teams_path student_id: params[:student_id]

      end
    elsif matching_teams.length == 1 && (matching_teams[0].name <=> team.name).zero?

      team_created_successfully
      redirect_to view_student_teams_path student_id: params[:student_id]

    else
      flash[:notice] = 'That team name is already in use.'

      redirect_to edit_student_teams_path team_id: params[:team_id], student_id: params[:student_id]

    end
  end

  def advertise_for_partners
    Team.update_all advertise_for_partner: true, id: params[:team_id]
  end

  def remove_advertisement
    Team.update_all advertise_for_partner: false, id: params[:team_id]
    redirect_to view_student_teams_path student_id: params[:team_id]
  end

  def remove_participant
    # remove the record from teams_users table
    team_user = TeamsUser.where(team_id: params[:team_id], user_id: student.user_id)

    if team_user
      team_user.destroy_all
      undo_link "The user \"#{team_user.name}\" has been successfully removed from the team."
    end

    # if your old team does not have any members, delete the entry for the team
    if TeamsUser.where(team_id: params[:team_id]).empty?
      old_team = AssignmentTeam.find params[:team_id]
      if old_team
        old_team.destroy
        # if assignment has signup sheet then the topic selected by the team has to go back to the pool
        # or to the first team in the waitlist
        sign_ups = SignedUpTeam.where team_id: params[:team_id]
        sign_ups.each do |sign_up|
          # get the topic_id
          sign_up_topic_id = sign_up.topic_id
          # destroy the sign_up
          sign_up.destroy
          # get the number of non-waitlisted users signed up for this topic
          non_waitlisted_users = SignedUpTeam.where topic_id: sign_up_topic_id, is_waitlisted: false
          # get the number of max-choosers for the topic
          max_choosers = SignUpTopic.find(sign_up_topic_id).max_choosers
          # check if this number is less than the max choosers
          next unless non_waitlisted_users.length < max_choosers
          first_waitlisted_team = SignedUpTeam.find_by topic_id: sign_up_topic_id, is_waitlisted: true
          # moving the waitlisted team into the confirmed signed up teams list and delete all waitlists for this team
          if first_waitlisted_team
            SignUpTopic.assign_to_first_waiting_team(first_waitlisted_team)
          end
        end
      end
    end

    # remove all the sent invitations
    old_invites = Invitation.where from_id: student.user_id, assignment_id: student.parent_id

    old_invites.each(&:destroy)

    student.save

    redirect_to view_student_teams_path student_id: student.id
  end

  def team_created_successfully(current_team = nil)
    if current_team
      undo_link "The team \"#{current_team.name}\" has been successfully updated."
    else
      undo_link "The team \"#{team.name}\" has been successfully updated."
    end
  end

  def review
    @assignment = Assignment.find params[:assignment_id]
    redirect_to view_questionnaires_path id: @assignment.questionnaires.find_by_type('AuthorFeedbackQuestionnaire').id
  end

  private

  # authorizations: reader,submitter, reviewer
  def are_needed_authorizations_present?
    @participant = Participant.find(params[:student_id])
    authorization = Participant.get_authorization(@participant.can_submit, @participant.can_review, @participant.can_take_quiz)
    if authorization == 'reader' or authorization == 'reviewer' or authorization == 'submitter'
      return false
    else
      return true
    end
  end
end
