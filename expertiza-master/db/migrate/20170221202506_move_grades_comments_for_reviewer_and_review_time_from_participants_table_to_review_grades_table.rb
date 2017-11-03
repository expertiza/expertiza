class MoveGradesCommentsForReviewerAndReviewTimeFromParticipantsTableToReviewGradesTable < ActiveRecord::Migration
  def change
  	Participant.all.each do |participant|
  		begin
	  		review_grades = ReviewGrade.create(
	  			participant_id: participant.id,
	  			grade_for_reviewer: participant.grade_for_reviewer,
	  			comment_for_reviewer: participant.comment_for_reviewer,
	  			review_graded_at: participant.review_graded_at)
	  	rescue => e
	  	end
	  end
  end
end
