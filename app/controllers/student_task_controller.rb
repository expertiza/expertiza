class StudentTaskController < ApplicationController
  helper :submitted_content

  def action_allowed?
    ['Instructor', 'Teaching Assistant', 'Administrator', 'Super-Administrator', 'Student'].include? current_role_name
  end

  def list
    redirect_to(controller: 'eula', action: 'display') if current_user.is_new_user
    session[:user] = User.find_by(id: current_user.id)

    list_student_tasks
    list_tasks_and_notifications
    list_students_teamed_with
  end

  def list_student_tasks
    # Get list of student tasks that are available and currently due then sort them by their due date.
    @all_tasks = StudentTask.from_user current_user
    @student_tasks = @all_tasks.select {|t| t.assignment.availability_flag }
    @student_tasks.select! {|t| t.stage_deadline.to_date > DateTime.now}.sort_by! {|k| k.stage_deadline}.reverse!
    @student_tasks = @student_tasks.paginate(page: params[:student_task_page], per_page: 10)

    list_past_due_tasks

  end

  def list_past_due_tasks
    # Get a list of student tasts that are past due and sort them by their due date.
    @past_student_tasks= @all_tasks.select {|t| t.stage_deadline.to_date < DateTime.now}
    if (!@past_student_tasks.nil?)
      @past_student_tasks.sort_by! {|k| k.stage_deadline}.reverse!
      @past_student_tasks = @past_student_tasks.paginate(page: params[:past_assignment_page], per_page: 10)
    end
  end

  def list_tasks_and_notifications
    # #######Tasks and Notifications##################
    @tasknotstarted = @student_tasks.select(&:not_started?)
    @taskrevisions = @student_tasks.select(&:revision?)
  end

  def list_students_teamed_with
    ######## Students Teamed With###################
    @students_teamed_with = StudentTask.teamed_students(current_user, session[:ip])
  end

  def view
    StudentTask.from_participant_id params[:id]

    init_participant

    denied unless current_user_id?(@participant.user_id)

    init_assignment

    init_timeline
   end

  def init_participant
    @participant = AssignmentParticipant.find(params[:id])
    @can_submit = @participant.can_submit
    @can_review = @participant.can_review
    @can_take_quiz = @participant.can_take_quiz
    @authorization = Participant.get_authorization(@can_submit, @can_review, @can_take_quiz)
    @team = @participant.team
  end

  def init_assignment
    @assignment = @participant.assignment
    @can_provide_suggestions = @assignment.allow_suggestions
    @topic_id = SignedUpTeam.topic_id(@assignment.id, @participant.user_id)
    @topics = SignUpTopic.where(assignment_id: @assignment.id)
  end

  def init_timeline
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

  def your_work; end
end
