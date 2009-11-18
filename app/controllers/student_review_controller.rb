class StudentReviewController < ApplicationController
  def list
    @participant = AssignmentParticipant.find(params[:id])
    @assignment = @participant.assignment
    # Finding the current phase that we are in
    @review_phase = @assignment.get_current_stage
             
    @review_mappings = ReviewMapping.find_all_by_reviewer_id(@participant.id)
    @metareview_mappings = ReviewOfReviewMapping.find_all_by_reviewer_id(@participant.id)    
  end  
  
end
