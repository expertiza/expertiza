require 'digital_sig'

class PublishingController < ApplicationController
  
  def view   
    @participants = AssignmentParticipant.find_all_by_user_id(session[:user].id)
  end
  
  def set_master_publish_permission        
    # if digital sig is verified then change settings
    if session[:dsig] 
      session[:user].update_attribute('master_permission_granted',params[:set_master])    
      session[:user].update_attribute('permission_updated_at',DateTime.now)  
      session[:user].update_attribute('digital_signature',session[:dsig])  
    else
      flash[:error] = 'You need to digitally sign before changing rights.'      
    end
    redirect_to :action => 'view'
  end
  
  def set_publish_permission
    # if digital sig is verified then change settings
    if session[:dsig] 
      participant = AssignmentParticipant.find(params[:id])
      participant.update_attribute('permission_granted',params[:allow])  
      participant.update_attribute('permission_updated_at',DateTime.now)    
      participant.update_attribute('digital_signature',session[:dsig])  
    else
      flash[:error] = 'You need to digitally sign before changing rights.'      
    end
    redirect_to :action => 'view'
  end  
  
  def update_publish_permissions
    # if digital sig is verified then change settings
    if session[:dsig] 
      participants = AssignmentParticipant.find_all_by_user_id(session[:user].id)
      participants.each{
        | participant |
        participant.update_attribute('permission_granted',params[:allow])  
        participant.update_attribute('permission_updated_at',DateTime.now)    
        participant.update_attribute('digital_signature',session[:dsig])  
      }    
    else
      flash[:error] = 'You need to digitally sign before changing rights.'      
    end
    redirect_to :action => 'view'
  end
  
  def get_private_key
     @username = session[:user].name
  end
  
  def validate_key
    ck_user = User.find_by_id(session[:user].id)
    
    # if no certificate set for user then generate
    if ck_user.certificate.nil?
      ck_user.gen_keys_and_certificate
    end 
    #puts "#{params[:private_key]}"
    # generate dig signature and validate using certificate
    pkey1 = params[:private_key]
    pkey1.gsub!(/\r/,"")
    
    begin
      # allow bypass of key entry for debug
      if pkey1 =~ /test bypass/
        session[:dsig] = "DEBUG: SIGNATURE TEST BYPASSED"
      else  
        session[:dsig]= DigitalSig.gen_digital_signature("MASTER", ck_user.name, pkey1, ck_user.certificate)
      end  
    rescue
      session[:dsig]= nil
    end  
    redirect_to :action => 'view'
  end
  
end
