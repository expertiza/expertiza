class StudentGroupsController < ApplicationController
  autocomplete :user, :name

  def group
    @group ||= AssignmentGroup.find params[:group_id]
  end

  attr_writer :group

  def student
    @student ||= AssignmentParticipant.find(params[:student_id])
  end

  attr_writer :student

  before_action :group, only: [:edit, :update]
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
      return group.get_participants.map(&:user_id).include? current_user.id if %w(edit update).include? action_name
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

    current_group = @student.group

    @users_on_waiting_list = if @student.assignment.has_topics? && current_group && current_group.topic
                               SignUpTopic.find(current_group.topic).users_on_waiting_list
                             end

    @groupmate_review_allowed = true if @student.assignment.find_current_stage == 'Finished' || @current_due_date && (@current_due_date.groupmate_review_allowed_id == 3 || @current_due_date.groupmate_review_allowed_id == 2) # late(2) or yes(3)
  end

  def create
    existing_assignments = AssignmentTeam.where name: params[:group][:name], parent_id: student.parent_id
    # check if the group name is in use
    if existing_assignments.empty?
      if params[:group][:name].nil? || params[:group][:name].empty?
        flash[:notice] = 'The group name is empty.'
        redirect_to view_student_groups_path student_id: student.id
        return
      end
      group = AssignmentTeam.new(name: params[:group][:name], parent_id: student.parent_id)
      group.save
      parent = AssignmentNode.find_by_node_object_id student.parent_id
      GroupNode.create parent_id: parent.id, node_object_id: group.id
      user = User.find student.user_id
      group.add_member user, group.parent_id
      group_created_successfully(group)
      redirect_to view_student_groups_path student_id: student.id

    else
      flash[:notice] = 'That group name is already in use.'
      redirect_to view_student_groups_path student_id: student.id
    end
  end

  def edit
  end

  def update
    matching_groups = AssignmentGroup.where name: params[:group][:name], parent_id: group.parent_id
    if matching_groups.length.zero?
      if group.update_attribute('name', params[:group][:name])
        group_created_successfully

        redirect_to view_student_groups_path student_id: params[:student_id]

      end
    elsif matching_groups.length == 1 && (matching_groups[0].name <=> group.name).zero?

      group_created_successfully
      redirect_to view_student_groups_path student_id: params[:student_id]

    else
      flash[:notice] = 'That group name is already in use.'

      redirect_to edit_student_groups_path group_id: params[:group_id], student_id: params[:student_id]

    end
  end

  def advertise_for_partners
    Group.update_all advertise_for_partner: true, id: params[:group_id]
  end

  def remove_advertisement
    Group.update_all advertise_for_partner: false, id: params[:group_id]
    redirect_to view_student_groups_path student_id: params[:group_id]
  end

  def remove_participant
    # remove the record from groups_users table
    group_user = GroupsUser.where(group_id: params[:group_id], user_id: student.user_id)

    if group_user
      group_user.destroy_all
      undo_link "The user \"#{group_user.name}\" has been successfully removed from the group."
    end

    # if your old group does not have any members, delete the entry for the group
    if GroupsUser.where(group_id: params[:group_id]).empty?
      old_group = AssignmentGroup.find params[:group_id]
      if old_group && !old_group.received_any_peer_review?
        old_group.destroy
        # if assignment has signup sheet then the topic selected by the group has to go back to the pool
        # or to the first group in the waitlist
        sign_ups = SignedUpGroup.where group_id: params[:group_id]
        sign_ups.each do |sign_up|
          # get the topic_id
          sign_up_topic_id = sign_up.topic_id
          # destroy the sign_up
          sign_up.destroy
          # get the number of non-waitlisted users signed up for this topic
          non_waitlisted_users = SignedUpGroup.where topic_id: sign_up_topic_id, is_waitlisted: false
          # get the number of max-choosers for the topic
          max_choosers = SignUpTopic.find(sign_up_topic_id).max_choosers
          # check if this number is less than the max choosers
          next unless non_waitlisted_users.length < max_choosers
          first_waitlisted_group = SignedUpGroup.find_by topic_id: sign_up_topic_id, is_waitlisted: true
          # moving the waitlisted group into the confirmed signed up groups list and delete all waitlists for this group
          if first_waitlisted_group
            SignUpTopic.assign_to_first_waiting_group(first_waitlisted_group)
          end
        end
      end
    end

    # remove all the sent invitations
    old_invites = Invitation.where from_id: student.user_id, assignment_id: student.parent_id

    old_invites.each(&:destroy)

    student.save

    redirect_to view_student_groups_path student_id: student.id
  end

  def group_created_successfully(current_group = nil)
    if current_group
      undo_link "The group \"#{current_group.name}\" has been successfully updated."
    else
      undo_link "The group \"#{group.name}\" has been successfully updated."
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
