class PublishingController < ApplicationController
  
  def view   
    @participants = AssignmentParticipant.find_all_by_user_id(session[:user].id)
  end
  
  def set_master_publish_permission
    session[:user].update_attribute('master_permission_granted',params[:id])    
    redirect_to :action => 'view'
  end
  
  def set_publish_permission
    participant = AssignmentParticipant.find(params[:id])
    participant.update_attribute('permission_granted',params[:allow])  
    redirect_to :action => 'view'
  end  
  
  def update_publish_permissions
    participants = AssignmentParticipant.find_all_by_user_id(session[:user].id)
    participants.each{
      | participant |
      participant.update_attribute('permission_granted',params[:allow])  
    }    
    redirect_to :action => 'view'
  end
end
