class ParticipantsController < ApplicationController
  auto_complete_for :user, :name
  
  def select
    if (session[:user].role_id != 4)
      @assignments = Assignment.find(:all, :conditions => ["instructor_id = ?", session[:user].id])
    else
      @assignments = Assignment.find(:all)
    end  
  end


  
  def list
    @assignment = Assignment.find(params[:id])
    @participants = @assignment.users
  end
  

  
  def add
    assignment = Assignment.find(params[:assignment_id])
    user = User.find_by_name(params[:user][:name])
    if user != nil
      if user.master_permission_granted
        participant = Participant.create(:assignment_id => assignment.id, :user_id => user.id, :permission_granted => true)
      else
        participant = Participant.create(:assignment_id => assignment.id, :user_id => user.id, :permission_granted => false)
      end
    else
      flash[:error] = "No user account exists with the name "+params[:user][:name]+". Please <a href='"+url_for(:controller=>'users',:action=>'new')+"'>create</a> the user first."
    end
    redirect_to :action => 'list', :id => assignment.id
  end
  
   
  def delete
    participant = Participant.find_by_user_id(params[:id])
    assignment_id = participant.assignment_id
    participant.destroy
    redirect_to :action => 'list', :id => assignment_id
  end 
end

