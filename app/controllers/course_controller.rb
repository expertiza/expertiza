# Provides Course functions
# Author: unknown
#
# Last modified: 7/18/2008
# By: ajbudlon

# change access permission from public to private or vice versa
class CourseController < ApplicationController
  autocomplete :user, :name
  require 'fileutils'

  def action_allowed?
    current_role_name.eql?("Instructor")
  end

  def auto_complete_for_user_name
    search = params[:user][:name].to_s
    @users = User.find_by_sql("select * from users where role_id=6") unless search.blank?
    render :inline => "<%= auto_complete_result @users, 'name' %>", :layout => false
  end
  # Creates a new course
  # if private is set to 1, then the course will
  # only be available to the instructor who created it.
  def new
    @private = params[:private]
  end

  # Modify an existing course
  def edit
    @course = Course.find(params[:id])
  end

  def update
    @course = Course.find(params[:id])
    if params[:course][:directory_path] and @course.directory_path != params[:course][:directory_path]
      begin
        FileHelper.delete_directory(@course)
      rescue
        flash[:error] = $!
      end

      begin
        FileHelper.create_directory_from_path(params[:course][:directory_path])
      rescue
        flash[:error] = $!
      end
    end
    @course.update_attributes(params[:course])
    undo_link("Course \"#{@course.name}\" has been updated successfully. ")
    redirect_to :controller => 'tree_display', :action => 'list'
  end

  def copy
    orig_course = Course.find(params[:id])
    new_course = orig_course.clone
    new_course.instructor_id = session[:user].id
    new_course.name = 'Copy of '+orig_course.name
    begin
      new_course.save!
      parent_id = CourseNode.get_parent_id
      if parent_id
        CourseNode.create(:node_object_id => new_course.id, :parent_id => parent_id)
      else
        CourseNode.create(:node_object_id => new_course.id)
      end

      undo_link("Course \"#{orig_course.name}\" has been copied successfully. The copy is currently associated with an existing location from the original course. This could cause errors for future submissions and it is recommended that the copy be edited as needed. ")
      redirect_to :controller => 'course', :action => 'edit', :id => new_course.id

    rescue
      flash[:error] = 'The course was not able to be copied: '+$!
      redirect_to :controller => 'tree_display', :action => 'list'
    end
  end

  # create a course
  def create
    @course = Course.new(params[:course])

    @course.instructor_id = session[:user].id
    begin
      @course.save!
      parent_id = CourseNode.get_parent_id
      if parent_id
        CourseNode.create(:node_object_id => @course.id, :parent_id => parent_id)
      else
        CourseNode.create(:node_object_id => @course.id)
      end
      FileHelper.create_directory(@course)
      undo_link("Course \"#{@course.name}\" has been created successfully. ")
      redirect_to :controller => 'tree_display', :action => 'list'
    rescue
      flash[:error] = $! #"The following error occurred while saving the course: #"+
        redirect_to :action => 'new'
    end
  end

  # delete the course
  def delete
    @course = Course.find(params[:id])
    begin
      FileHelper.delete_directory(@course)
    rescue
      flash[:error] = $!
    end

    # already taken care of in association declaration
    #@course.ta_mappings.each{
    #  | map |
    #  map.destroy
    #}
    @course.destroy
    undo_link("Course \"#{@course.name}\" has been deleted successfully. ")
    redirect_to :controller => 'tree_display', :action => 'list'
  end

  def toggle_access
    @course = Course.find(params[:id])
    @course.private = !@course.private
    begin
      @course.save!
    rescue
      flash[:error] = $!
    end
    @access = @course.private == true ? "private" : "public"
    undo_link("Course \"#{@course.name}\" has been made #{@access} successfully. ")
    redirect_to :controller => 'tree_display', :action => 'list'
  end

  def view_teaching_assistants
    @course = Course.find(params[:id])
    @ta_mappings = @course.ta_mappings
  end

  def add_ta
    @course = Course.find(params[:course_id])
    @user = User.find_by_name(params[:user][:name])
    if(@user==nil)
      redirect_to :action => 'view_teaching_assistants', :id => @course.id
    else
      @ta_mapping = TaMapping.create(:ta_id => @user.id, :course_id => @course.id)
      @user.role=Role.find_by_name 'Teaching Assistant'
      @user.save

      redirect_to :action => 'view_teaching_assistants', :id => @course.id

      @course = @ta_mapping
      undo_link("TA \"#{@user.name}\" has been added successfully. ")
    end
  end

  def remove_ta
    @ta_mapping = TaMapping.find(params[:id])
    @ta = User.find(@ta_mapping.ta_id)
    @ta.role = Role.find_by_name 'Student'
    @ta.save
    @ta_mapping.destroy

    @course = @ta_mapping
    undo_link("TA \"#{@ta.name}\" has been removed successfully. ")

    redirect_to :action => 'view_teaching_assistants', :id => @ta_mapping.course
  end

  # generate the undo link
  #def undo_link
  #  "<a href = #{url_for(:controller => :versions,:action => :revert,:id => @course.versions.last.id)}>undo</a>"
  #end

end
