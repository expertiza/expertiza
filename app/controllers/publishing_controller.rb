class PublishingController < ApplicationController
  
  def view   
    @user = User.find_by_id(session[:user].id) 
    @participants = AssignmentParticipant.find_all_by_user_id(session[:user].id)
  end
  
  def set_publish_permission
    participant = AssignmentParticipant.find(params[:id])
    participant.update_attribute('permission_granted',params[:allow])  
    redirect_to :action => 'view'
  end  
  
  def update_publish_permissions
    if (params[:allow] == '1')
      redirect_to :action => 'grant'
    else
      participants = AssignmentParticipant.find_all_by_user_id(session[:user].id)
      participants.each{
        | participant |
        participant.update_attribute('permission_granted',params[:allow])  
        participant.digital_signature = nil
        participant.time_stamp = nil
        participant.save
      }
      redirect_to :action => 'view'
    end
  end

  # Put up the page where the user can supply their private key and grant publishing rights
  def grant
    # Lookup the specific assignment (if any) that the user is granting publishing rights to.
    # This will be nil when the user is granting to all past assignments.
    if (!params[:id].nil?) 
      @participant = AssignmentParticipant.find(params[:id])
    end
    @user = User.find_by_id(session[:user].id) 
  end
  
  # Grant publishing rights using the private key supplied by the student
  def grant_with_private_key
    if (params[:id])
      participants = [ AssignmentParticipant.find(params[:id]) ]
    else
      participants = AssignmentParticipant.find_all_by_user_id(session[:user].id)
    end
    private_key = params[:private_key]

    begin
      #check to see if key is valid, if so, then grant
      if(verify_digital_signature(private_key))
        AssignmentParticipant.grant_publishing_rights(private_key, participants)
        redirect_to :action => 'view'
      else
      	#key not valid, let user know and return to page
        flash[:notice] = 'Invalid private key.'
        if (!params[:id].nil?) 
          redirect_to :action => 'grant', :id => participants[0].id
        else
          redirect_to :action => 'grant'
        end
      end
    rescue
      flash[:notice] = 'Invalid private key.'
      if (!params[:id].nil?) 
        redirect_to :action => 'grant', :id => participants[0].id
      else
        redirect_to :action => 'grant'
      end
    end
  end
end
