class StudentReviewController < ApplicationController
  def list
    @participant = AssignmentParticipant.find(params[:id])
    @assignment = @participant.assignment
    # Finding the current phase that we are in
    @review_phase = @assignment.get_current_stage
    
    if @assignment.team_assignment
      @review_mappings = TeamReviewResponseMap.find_all_by_reviewer_id(@participant.id)
    else           
      @review_mappings = ParticipantReviewResponseMap.find_all_by_reviewer_id(@participant.id)
    end
    
    @metareview_mappings = MetareviewResponseMap.find_all_by_reviewer_id(@participant.id)    
  end  
  
end
