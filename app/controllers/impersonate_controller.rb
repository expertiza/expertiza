class ImpersonateController < ApplicationController
  def auto_complete_for_user_name
    curr_user = session[:user]
    role = Role.find(curr_user.role_id)    
    if role.name == "instructor" || role.name == "teaching assistant"
      user_ids = Array.new
      assignments = Assignment.find(:all, :conditions => ['instructor_id = ?',(session[:user]).id])
      assignments.each { | assignment |
         participants = Participant.find(:all, :conditions => ['assignment_id = ?',assignment.id])
         participants.each { | participant |
            user_ids << participant.user_id
         }
      }
      courses = Course.find(:all, :conditions => ['instructor_id = ?',(session[:user]).id])
      courses.each { | course |
        course_users = CoursesUsers.find(:all, :conditions => ['course_id = ?',course.id])
        course_users.each { | course_user |          
          user_ids << course_user.user_id
        }
      } 
      @users = User.find(:all, :conditions => ['name LIKE ? and id in (?)',"#{params[:user][:name]}%",user_ids], :limit => 10)          
    else
      @users = User.find(:all, :conditions => ['name LIKE ?',"#{params[:user][:name]}%"],:limit => 10)
    end
    render :inline => "<%= auto_complete_result @users, 'name' %>", :layout => false
  end

  def start     
     
  end
 
  def impersonate   
     user = User.find_by_name(params[:user][:name])
     if user
        if session[:super_user] == nil
          session[:super_user] = session[:user]
        end
        session[:user] = user 
        ImpersonateHelper::display_user_view(session,logger)     
        redirect_to :controller =>'student_assignment', :action => 'list'
     else 
        flash[:error] = "No user exists with the name '#{params[:user][:name]}'"
        redirect_to :back
     end
   
  end
  
  def restore
      if session[:super_user] != nil
        session[:user] = session[:super_user]
        session[:super_user] = nil
        ImpersonateHelper::display_user_view(session,logger)
        redirect_to :controller =>'assignment', :action => 'list'
      else
        redirect_to :back
      end 
  end
end
