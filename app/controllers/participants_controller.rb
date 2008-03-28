class ParticipantsController < ApplicationController
  auto_complete_for :user, :name
  
  def list_students
   user_id = session[:user].id
   @user_pages, @users = paginate :users, :order => 'name',:conditions => ["parent_id = ? AND role_id = ?", user_id, Role::STUDENT], :per_page => 50
  end
  
  def new_student
    # Creates a new instance of student, with default values    
      @user = User.new      
      # these values need to be true by default so new users receive e-mail on these events unless they opt not to
      @user.email_on_review = true
      @user.email_on_submission = true
      @user.email_on_review_of_review = true      
  end
  
  def create_student
    # Saves the current instance of students in the db.
     @user = User.new
     @user.update_attributes(params[:user])     
    @user.parent_id = (session[:user]).id
    @user.role_id = Role::STUDENT     
    if params[:user][:clear_password].length == 0 or
        params[:user][:confirm_password] != params[:user][:clear_password]
      flash[:error] = 'Password invalid!'
      render :action => 'new_student'
    else
      if @user.save
        flash[:notice] = 'Student was successfully created.'
        redirect_to :action => 'list_students'
      else
        render :action => 'new_student'
      end
    end    
  end
  
  def show_student
    @user = User.find(params[:id])
    if @user.role_id
      @role = Role.find(@user.role_id)
    else
      @role = Role.new(:id => nil, :name => '(none)')
    end
  end
  
   def edit_student
    @user = User.find(params[:id])
    if @user.role_id
      @role = Role.find(@user.role_id)
    end
  end
  
   def update_student
    @user = User.find(params[:id])
    if params[:user]['clear_password'] == ''
      params[:user].delete('clear_password')
    end

    if params[:user][:clear_password] and
        params[:user][:clear_password].length > 0 and
        params[:user][:confirm_password] != params[:user][:clear_password]
      flash[:error] = 'Password invalid!'
      foreign
      render :action => 'edit_student'
    else
      if @user.update_attributes(params[:user])
        flash[:notice] = 'Student was successfully updated.'
        redirect_to :action => 'show_student', :id => @user
      else
        foreign
        render :action => 'edit'
      end
    end
  end
  
   def remove_student
    User.find(params[:id]).destroy
    redirect_to :action => 'list_students'
  end
  
  def list_courses
    @courses = Course.find(:all, :order => 'title',:conditions => ["instructor_id = ?", session[:user].id])
  end
  
  def list_assignments
    @assignments = Assignment.find(:all, :conditions => ["instructor_id = ? and team_assignment = 0", session[:user].id])
  end

  def view_participants
    @course = Course.find(params[:id])
    @participants = @course.users
  end
  
  def view_assignment_participants
    @assignment = Assignment.find(params[:id])
    @participants = @assignment.users
  end
  
  def add_participant
    @course = Course.find(params[:course_id])
    @user = User.find_by_name(params[:user][:name])
    if(@user==nil)
      redirect_to :action => 'new_student', :name => params[:user][:name]
    else
      @course.users << @user
      redirect_to :action => 'view_participants', :id => @course
    end    
  end
  
  def add_assignment_participant
    @assignment = Assignment.find(params[:assignment_id])
    @user = User.find_by_name(params[:user][:name])
    if(@user==nil)
      redirect_to :action => 'new_student', :name => params[:user][:name]
    else
      if @user.master_permission_granted
        @participant = Participant.create(:assignment_id => @assignment.id, :user_id => @user.id, :permission_granted => true)
      else
        @participant = Participant.create(:assignment_id => @assignment.id, :user_id => @user.id, :permission_granted => false)
      end
      redirect_to :action => 'view_assignment_participants', :id => @assignment
    end
  end
  
   
  def remove_participant
    @course = Course.find(params[:course_id])
    @user = @course.users.find_by_id(params[:id])
    @course.users.delete(@user)
    redirect_to :action => 'view_participants', :id => @course
  end
  
  def remove_assignment_participant
    @assignment = Assignment.find(params[:assignment_id])
    @user = @assignment.users.find_by_id(params[:id])
    @participant = Participant.find(:first, :conditions => ['assignment_id =? and user_id = ?', @assignment.id, @user.id])   
    @participant.destroy
    redirect_to :action => 'view_assignment_participants', :id => @assignment
  end
  
  def edit_assignment_participants
  end
  
  def edit_participants
    @course_action = 'view_participants'
    @my_controller = 'participants'
    @courses_pages, @courses = paginate :courses, :order => 'title',:conditions => ["instructor_id = ?", session[:user].id], :per_page => 10
  end
  
  def edit_team_members
  end     
end

