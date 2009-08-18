class ParticipantsController < ApplicationController
  auto_complete_for :user, :name
  
  def list
    @root_node = Object.const_get(params[:model]+"Node").find_by_node_object_id(params[:id])     
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
    participant = Participant.find(params[:id])
    parent_id = participant.parent_id
    if participant.type.to_s == 'AssignmentParticipant'
      model = 'Assignment'
    else
      model = 'Course'
    end
    participant.delete
    redirect_to :action => 'list', :id => parent_id, :model => model
  end
  
 # Copies existing participants from a course down to an assignment
 def inherit
   assignment = Assignment.find(params[:id])
   if assignment.course_id > 0
    course = Course.find(assignment.course_id)
    participants = course.get_participants
    if participants.length > 0 
      participants.each{
        |participant|
        participant.copy(assignment.id)
      }
    else
      flash[:note] = "No participants were found to inherit."
    end
   else
     flash[:error] = "No course was found for this assignment."
   end
   redirect_to :controller => 'participants', :action => 'list', :id => assignment.id, :model => 'Assignment'   
 end
 
 def bequeath_all   
   assignment = Assignment.find(params[:id])
   if assignment.course_id
      course = Course.find(assignment.course_id)
      assignment.get_participants.each{
        |participant|
        participant.copy(course.id)
      }
      flash[:note] = "All participants were successfully copied to \""+course.name+"\""
   else
      flash[:error] = "This assignment is not associated with a course."
   end
   redirect_to :controller => 'participants', :action => 'list', :id => assignment.id, :model => 'Assignment' 
 end     
  
  # Allow participant to change handle for this assignment
  # If the participant parameters are available, update the participant
  # and redirect to the view_actions page
  def change_handle
    @participant = AssignmentParticipant.find(params[:id])  
    if params[:participant] != nil
      @participant.update_attributes(params[:participant])
      redirect_to :controller => 'student_assignment', :action => 'view_actions', :id => @participant      
    end
  end   
end
