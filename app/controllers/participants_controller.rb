class ParticipantsController < ApplicationController
  auto_complete_for :user, :name
  
  def list
    @parent = Object.const_get(params[:model]).find(params[:id])
    @participants = @parent.get_participants  
    @model = params[:model]    
  end
  
  def add    
    curr_object = Object.const_get(params[:model]).find(params[:id])    
    begin
      curr_object.add_participant(params[:user][:name])
    rescue
      flash[:error] = $!
    end
    redirect_to :action => 'list', :id => curr_object.id, :model => params[:model]
  end
    
  def delete
    participant = Participant.find_by_user_id(params[:id])
    parent_id = participant.parent_id
    if participant.type.to_s == 'AssignmentParticipant'
      model = 'Assignment'
    else
      model = 'Course'
    end
    participant.destroy
    redirect_to :action => 'list', :id => parent_id, :model => model
  end   
end
