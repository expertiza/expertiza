class SubmittedContentController < ApplicationController
  helper :wiki
  
  def edit
    @participant = AssignmentParticipant.find(params[:id])
    @assignment = @participant.assignment
  end
  
  def view
    @participant = AssignmentParticipant.find(params[:id])
    @assignment = @participant.assignment
  end  
end
