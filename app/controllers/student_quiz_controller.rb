class StudentQuizController < ApplicationController
  def list
    @participant = AssignmentParticipant.find(params[:id])
    return unless current_user_id?(@participant.user_id)

    @assignment  = @participant.assignment

    # Find the current phase that the assignment is in.
    @quiz_phase = @assignment.get_current_stage(AssignmentParticipant.find(params[:id]).topic_id)


      @quiz_mappings = QuizResponseMap.find_all_by_reviewer_id(@participant.id)

    # Calculate the number of quizzes that the user has completed so far.
    @num_quizzes_total       = @quiz_mappings.size

    @num_quizzes_completed   = 0
    @quiz_mappings.each do |map|
      @num_quizzes_completed += 1 if map.response
    end


    if @assignment.staggered_deadline?
      @quiz_mappings.each { |quiz_mapping|
          if @assignment.team_assignment?
            participant = AssignmentTeam.get_first_member(quiz_mapping.reviewee_id)
          else
            participant = quiz_mapping.reviewee
          end

          if !participant.nil? and !participant.topic_id.nil?
            quiz_due_date = TopicDeadline.find_by_topic_id_and_deadline_type_id(participant.topic_id,1)
          end
        }

        deadline_type_id = DeadlineType.find_by_name('quiz').id
      end
  end
end
