class StudentTaskController < ApplicationController
  helper :submitted_content

  def action_allowed?
    ['Instructor', 'Teaching Assistant', 'Administrator', 'Super-Administrator', 'Student'].include? current_role_name
  end

  def impersonating_as_admin?
    original_user = session[:original_user]
    admin_role_ids = Role.where(name:['Administrator','Super-Administrator']).pluck(:id)
    admin_role_ids.include? original_user.role_id
  end

  def impersonating_as_ta?
    original_user = session[:original_user]
    ta_role = Role.where(name:['Teaching Assistant']).pluck(:id)
    ta_role.include? original_user.role_id
  end

  def list
    redirect_to(controller: 'eula', action: 'display') if current_user.is_new_user
    session[:user] = User.find_by(id: current_user.id)
    @student_tasks = StudentTask.from_user current_user
    if session[:impersonate] && !impersonating_as_admin?

      if impersonating_as_ta?
        ta_course_ids = TaMapping.where(:ta_id => session[:original_user].id).pluck(:course_id)
        @student_tasks = @student_tasks.select {|t| ta_course_ids.include?t.assignment.course_id }
      else
        # Changed logic to adapt to free standing assignments with the same course ID
        @student_tasks = @student_tasks.select do |t|
          session[:original_user].id == if t.assignment.course.nil?
                                          t.assignment.instructor_id
                                        else
                                          t.assignment.course.instructor_id
                                        end
        end
      end
    end

    @student_tasks.select! {|t| t.assignment.availability_flag } unless @assignment.nil?

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
    @authorization = Participant.get_authorization(@can_submit, @can_review, @can_take_quiz)
    @team = @participant.team
    denied unless current_user_id?(@participant.user_id)
    @assignment = @participant.assignment
    @can_provide_suggestions = @assignment.allow_suggestions
    @topic_id = SignedUpTeam.topic_id(@assignment.id, @participant.user_id)
    @topics = SignUpTopic.where(assignment_id: @assignment.id)
    # Timeline feature
    @timeline_list = StudentTask.get_timeline_data(@assignment, @participant, @team)
  end

  def others_work
    @participant = AssignmentParticipant.find(params[:id])
    return unless current_user_id?(@participant.user_id)

    @assignment = @participant.assignment
    # Finding the current phase that we are in
    due_dates = AssignmentDueDate.where(parent_id: @assignment.id)
    @very_last_due_date = AssignmentDueDate.where(parent_id: @assignment.id).order("due_at DESC").limit(1)
    next_due_date = @very_last_due_date[0]
    for due_date in due_dates
      if due_date.due_at > Time.now
        next_due_date = due_date if due_date.due_at < next_due_date.due_at
      end
    end

    @review_phase = next_due_date.deadline_type_id
    if next_due_date.review_of_review_allowed_id == DeadlineRight::LATE or next_due_date.review_of_review_allowed_id == DeadlineRight::OK
      @can_view_metareview = true if @review_phase == DeadlineType.find_by(name: "metareview").id
    end

    @review_mappings = ResponseMap.where(reviewer_id: @participant.id)
    @review_of_review_mappings = MetareviewResponseMap.where(reviewer_id: @participant.id)
  end

  # To give permission for making a submission available to others
  def make_public
    @team = Team.find(params[:id])
    @team.make_public = params[:status]
    @team.save
    respond_to do |format|
      format.html { head :no_content }
    end
  end

  def your_work; end
end
