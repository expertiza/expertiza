class StudentTaskController < ApplicationController
  include AuthorizationHelper

  helper :submitted_content

  def action_allowed?
    current_user_has_student_privileges?
  end

  def impersonating_as_admin?
    original_user = session[:original_user]
    admin_role_ids = Role.where(name: %w[Administrator Super-Administrator]).pluck(:id)
    admin_role_ids.include? original_user.role_id
  end

  def impersonating_as_ta?
    original_user = session[:original_user]
    ta_role = Role.where(name: ['Teaching Assistant']).pluck(:id)
    ta_role.include? original_user.role_id
  end

  def controller_locale
    locale_for_student
  end

  def list
    if current_user.is_new_user
      redirect_to(controller: 'eula', action: 'display')
    end
    session[:user] = User.find_by(id: current_user.id)
    @student_tasks = StudentTask.from_user current_user
    if session[:impersonate] && !impersonating_as_admin?

      if impersonating_as_ta?
        ta_course_ids = TaMapping.where(ta_id: session[:original_user].id).pluck(:course_id)
        @student_tasks.select! { |t| ta_course_ids.include? t.assignment.course_id }
      else
        @student_tasks.select! { |t| t.assignment.course && (session[:original_user].id == t.assignment.course.instructor_id) || !t.assignment.course && (session[:original_user].id == t.assignment.instructor_id) }
      end
    end
    @student_tasks.select! { |t| t.assignment.availability_flag }

    # #######Tasks and Notifications##################
    @tasknotstarted = @student_tasks.select(&:not_started?)
    @taskrevisions = @student_tasks.select(&:revision?)

    ######## Students Teamed With###################
    @students_teamed_with = StudentTask.teamed_students(current_user, session[:ip])
  end

  def view
    StudentTask.from_participant_id params[:id]
    @participant = AssignmentParticipant.find(params[:id])
    @can_submit = @participant.can_submit
    @can_review = @participant.can_review
    @can_take_quiz = @participant.can_take_quiz
    @authorization = @participant.authorization
    @team = @participant.team
    denied unless current_user_id?(@participant.user_id)
    @assignment = @participant.assignment
    @can_provide_suggestions = @assignment.allow_suggestions
    @topic_id = SignedUpTeam.topic_id(@assignment.id, @participant.user_id)
    @topics = SignUpTopic.where(assignment_id: @assignment.id)
    @use_bookmark = @assignment.use_bookmark
    # Timeline feature
    @timeline_list = StudentTask.get_timeline_data(@assignment, @participant, @team)
    # To get the current active reviewers of a team assignment.
    # Used in the view to disable or enable the link for sending email to reviewers.
    @review_mappings = review_mappings(@assignment, @team.id) if @team
  end

  def others_work
    @participant = AssignmentParticipant.find(params[:id])
    return unless current_user_id?(@participant.user_id)

    @assignment = @participant.assignment
    # Finding the current phase that we are in
    due_dates = AssignmentDueDate.where(parent_id: @assignment.id)
    @very_last_due_date = AssignmentDueDate.where(parent_id: @assignment.id).order('due_at DESC').limit(1)
    next_due_date = @very_last_due_date.first
    due_dates.each do |due_date|
      if due_date.due_at > Time.now
        next_due_date = due_date if due_date.due_at < next_due_date.due_at
      end
    end

    @review_phase = next_due_date.deadline_type_id
    if (next_due_date.review_of_review_allowed_id == DeadlineRight::LATE) || (next_due_date.review_of_review_allowed_id == DeadlineRight::OK)
      if @review_phase == DeadlineType.find_by(name: 'metareview').id
        @can_view_metareview = true
      end
    end

    @review_mappings = ResponseMap.where(reviewer_id: @participant.id)
    @review_of_review_mappings = MetareviewResponseMap.where(reviewer_id: @participant.id)
  end

  def publishing_rights_update
    @participant = AssignmentParticipant.find(params[:id])
    @participant.permission_granted = params[:status]
    @participant.save
    respond_to do |format|
      format.html { head :no_content }
    end
  end

  def email_reviewers; end

  # This method is used to send email from Author to Reviewers.
  # Email body and subject are inputted from Author and passed to send_mail_to_author_reviewers method in mailhelper.
  def send_email
    subject = params['send_email']['subject']
    body = params['send_email']['email_body']
    participant_id = params['participant_id']
    assignment_id = params['assignment_id']
    @participant = AssignmentParticipant.find_by(id: participant_id)
    @team = Team.find_by(parent_id: assignment_id)

    mappings = review_mappings(assignment_id, @team.id)
    respond_to do |format|
      if subject.blank? || body.blank?
        flash[:error] = 'Please fill in the subject and the email content.'
        format.html { redirect_to controller: 'student_task', action: 'email_reviewers', id: @participant, assignment_id: assignment_id }
        format.json { head :no_content }
      else
        # make a call to method invoking the email process
        unless mappings.length.zero?
          mappings.each do |mapping|
            reviewer = mapping.reviewer.user
            MailerHelper.send_mail_to_author_reviewers(subject, body, reviewer.email)
          end
        end
        flash[:success] = 'Email sent to the reviewers.'
        format.html { redirect_to controller: 'student_task', action: 'list' }
        format.json { head :no_content }
      end
    end
  end

  # retrieves review mappings for an assignment from ResponseMap table.
  def review_mappings(assignment_id, team_id)
    ResponseMap.where(reviewed_object_id: assignment_id,
                      reviewee_id: team_id,
                      type: 'ReviewResponseMap')
  end

  def your_work; end
end
