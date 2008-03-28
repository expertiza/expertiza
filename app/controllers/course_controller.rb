class CourseController < ApplicationController
  auto_complete_for :user, :name
  
  require 'ftools'
  def get_courses_in_folder(curr_dir)
    Course.find(:all,
                :conditions => ["instructor_id = ? AND directory_path LIKE ?", 
                                session[:user].id, curr_dir + "%"])
  end

  def list_folders
    # the default directory to display is your username
    @curr_dir = session[:user].name + "/"
    if params[:curr_dir] then
      @curr_dir = params[:curr_dir] + "/"
    end
    files = Dir[@curr_dir + "*"]
    @folders = Array.new
    for file in files
      print Dir.pwd + file + "\n";
      if File.directory?(Dir.pwd + "/" + file) then
        @folders << file
      end
    end
    
    @courses = get_courses_in_folder @curr_dir
  end
  
  def list_courses
    @courses = Course.find(:all,
                :conditions => ["instructor_id = ?", session[:user].id])
  end

  def self.remove_last_slash(dir)
    # removes the final character from a directory path
    # if the character is a slash 
    if dir[-1]==47
      dir = dir[0..dir.length-2]
    end
    dir
  end

  def new_folder
    curr_dir = ""
    if params[:folder][:name] then
      if params[:curr_dir] then
        curr_dir = params[:curr_dir]
      end
      
      begin
        # Create submission directory for this assignment
        File.makedirs(curr_dir + params[:folder][:name])
        
        flash[:notice] = "New Folder has been created"
      rescue
        flash[:notice] = "<font color=red> Folder already exists</font>"
      end
    end
    
    redirect_to :action => "list_folders", :curr_dir => CourseController.remove_last_slash(curr_dir)
  end
  
  def new_course
    @course = Course.new
    if params[:curr_dir] then
      @course.directory_path = params[:curr_dir]
    end
  end
  
  def create_course
    @course = Course.new(params[:course])
    # Sets the instructor for a course
    @course.instructor_id = session[:user].id
    if @course.save
      flash[:notice] = 'Course was successfully created.'
      redirect_to :action => 'list_folders'
    else
      # if the save fails then show error messages to the user
      render :action => 'new_course'
    end
  end

  def edit_course
    @course = Course.find(params[:id])
  end

  def update_course
    @course = Course.find(params[:id])
    if @course.update_attributes(params[:course])
      flash[:notice] = 'Course was successfully updated.'
      redirect_to :action => 'list_folders', :id => @course
    else
      render :action => 'edit_course'
    end
  end

  def destroy_course
    Course.find(params[:id]).destroy
    redirect_to :action => 'list_folders'
  end
  
  def view_teaching_assistants
    @course = Course.find(params[:id])
    ta_mappings = @course.ta_mappings
    @ta_users = []
    for mappings in ta_mappings
      @ta_users << mappings.ta
    end
  end
  
  def add_ta
    @course = Course.find(params[:course_id])
    @user = User.find_by_name(params[:user][:name])
    if(@user==nil)
      redirect_to :action => 'view_teaching_assistants', :id => @course.id 
    else
      @ta_mapping = TaMapping.create(:ta_id => @user.id, :course_id => @course.id)
      redirect_to :action => 'view_teaching_assistants', :id => @course.id
    end
  end 
  
  def remove_ta
    @course = Course.find(params[:course_id])
    @ta_mapping = TaMapping.find(:first, 
                                   :conditions =>["course_id = ? AND ta_id = ?", 
                                    params[:course_id], params[:id]])
    @ta_mapping.destroy
    redirect_to :action => 'view_teaching_assistants', :id => @course
  end
end