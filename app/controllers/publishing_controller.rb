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

  def grant
      @participant = AssignmentParticipant.find(params[:id])
  end
  
  def grant_with_signature
    participant = AssignmentParticipant.find(params[:id])
    digital_signature = params[:digital_signature]

    verified = participant.verify_digital_signature(digital_signature)
    if (verified)
      participant.update_attribute('permission_granted', 1)
      redirect_to :action => 'view'
    else
      flash[:notice] = 'Digital signature was not valid.'
      redirect_to :action => 'grant', :id => participant.id
    end
  end

  def grant_with_private_key
    participant = AssignmentParticipant.find(params[:id])
    private_key = params[:private_key]

    begin
      digital_signature = participant.generate_digital_signature(private_key)

      verified = participant.verify_digital_signature(digital_signature)
      if (verified)
        participant.update_attribute('permission_granted', 1)
        redirect_to :action => 'view'
      else
        flash[:notice] = 'Digital signature was not valid.'
        redirect_to :action => 'grant', :id => participant.id
      end
    rescue
      flash[:notice] = 'Invalid private key.'
      redirect_to :action => 'grant', :id => participant.id
    end
  end
end
