class CoursesUsersController < ApplicationController
  auto_complete_for :user, :name
  
  def add
    course = Course.find(params[:course_id])
    user = User.find_by_name(params[:user][:name])
    if user != nil      
      course.users << user
    else
      flash[:error] = "No user account exists with the name "+params[:user][:name]+". Please <a href='"+url_for(:controller=>'users',:action=>'new')+"'>create</a> the user first."
    end
    redirect_to :action => 'list', :id => course.id
  end
  
  def select
    @courses = Course.find(:all, :order => 'title',:conditions => ["instructor_id = ?", session[:user].id])
  end

  def new
    course = Course.find(params[:course_id])
    user = User.find_by_name(params[:user][:name])
    if(user==nil)      
    else
      @course.users << @user
      redirect_to :action => 'list', :id => course.id
    end    
  end
    
  def list
    @course = Course.find(params[:id])
    @course_users = @course.users   
  end
  
  def delete
    course_user = CoursesUsers.find(params[:id])
    course_id = course_user.course_id
    course_user.destroy
    redirect_to :action => 'list', :id => course_id
  end  
  
end
