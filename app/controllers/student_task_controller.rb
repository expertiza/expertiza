class StudentTaskController < ApplicationController
  helper :submitted_content

  def action_allowed?
    current_role_name.eql?("Student")
  end


  def list
    redirect_to(:controller => 'eula', :action => 'display') if current_user.is_new_user
    @student_tasks = StudentTask.from_user current_user

    ########Tasks and Notifications##################
    @tasknotstarted = @student_tasks.select(&:not_started?)
    @taskrevisions = @student_tasks.select(&:revision?)
    @notifications = @student_tasks.select(&:notify?)
  end

  def view
    StudentTask.from_participant_id params[:id]
    @participant = AssignmentParticipant.find(params[:id])
    denied unless current_user_id?(@participant.user_id)

    @assignment = @participant.assignment
    @can_provide_suggestions = @assignment.allow_suggestions
    #Even if one of the reviewee's work is ready for review "Other's work" link should be active
    if @assignment.staggered_deadline?
      review_mappings = @participant.team_reviews

      review_mappings.each do |review_mapping|
        participant = AssignmentTeam.get_first_member(review_mapping.reviewee_id)

        if participant && participant.topic
          review_due_date = TopicDeadline.where(topic_id: participant.topic_id, deadline_type_id:  1).first

          if review_due_date.due_at < Time.now && @assignment.get_current_stage(participant.topic_id) != 'Complete'
            @reviewee_topic_id = participant.topic_id
          end
        end
      end
    end
  end

  def others_work
    @participant = AssignmentParticipant.find(params[:id])
    return unless current_user_id?(@participant.user_id)

    @assignment = @participant.assignment
    # Finding the current phase that we are in
    due_dates = DueDate.where( ["assignment_id = ?", @assignment.id])
    @very_last_due_date = DueDate.order("due_at DESC").limit(1).where( ["assignment_id = ?", @assignment.id])
    next_due_date = @very_last_due_date[0]
    for due_date in due_dates
      if due_date.due_at > Time.now
        if due_date.due_at < next_due_date.due_at
          next_due_date = due_date
        end
      end
    end

    @review_phase = next_due_date.deadline_type_id;
    if next_due_date.review_of_review_allowed_id == DueDate::LATE or next_due_date.review_of_review_allowed_id == DueDate::OK
      if @review_phase == DeadlineType.find_by_name("metareview").id
        @can_view_metareview = true
      end
    end

    @review_mappings = ResponseMap.where(reviewer_id: @participant.id)
    @review_of_review_mappings = MetareviewResponseMap.where(reviewer_id: @participant.id)
  end

  def your_work

  end
end
