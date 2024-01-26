# Provides Course functions
# Author: unknown
#
# Last modified: 7/18/2008
# By: ajbudlon

# change access permission from public to private or vice versa
class CoursesController < ApplicationController
  include AuthorizationHelper

  autocomplete :user, :name
  require 'fileutils'

  def action_allowed?
    current_user_has_instructor_privileges?
  end

  def auto_complete_for_user_name
    search = params[:user][:name].to_s
    @users = User.where(role_id: 6) if search.present?
    render inline: "<%= auto_complete_result @users, 'name' %>", layout: false
  end

  # Creates a new course
  # if private is set to 1, then the course will
  # only be available to the instructor who created it.
  def new
    @private = params[:private]
  end

  # GET /courses/1/edit
  def edit
    @course = Course.find(params[:id])
  end

  # POST /courses
  def update
    @course = Course.find(params[:id])
    unless params[:course][:directory_path].nil? || @course.directory_path == params[:course][:directory_path]
      begin
        FileHelper.delete_directory(@course)
      rescue StandardError
        flash[:error] = $ERROR_INFO
      end

      begin
        FileHelper.create_directory_from_path(params[:course][:directory_path])
      rescue StandardError
        flash[:error] = $ERROR_INFO
      end
    end
    set_course_fields(@course)
    @course.save
    undo_link("The course \"#{@course.name}\" has been updated successfully.")
    redirect_to controller: 'tree_display', action: 'list'
  end

  # Create a copy of a course with a new submission directory
  def copy
    orig_course = Course.find(params[:id])
    new_course = orig_course.dup
    new_course.instructor_id = session[:user].id
    new_course.name = 'Copy of ' + orig_course.name
    new_course.directory_path = new_course.directory_path + '_copy'
    begin
      new_course.save!
      parent_id = CourseNode.get_parent_id
      if parent_id
        CourseNode.create(node_object_id: new_course.id, parent_id: parent_id)
      else
        CourseNode.create(node_object_id: new_course.id)
      end

      undo_link("The course \"#{orig_course.name}\" has been successfully copied.
        Warning: The submission directory path for this copy is the original course's directory path appended with the word \"_copy\".
        If you do not want this to happen, change the submission directory in the new copy of the course.")
      redirect_to controller: 'courses', action: 'edit', id: new_course.id
    rescue StandardError
      flash[:error] = 'The course was not able to be copied: ' + $ERROR_INFO
      redirect_to controller: 'tree_display', action: 'list'
    end
  end

  # create a course
  def create
    @course = Course.new
    set_course_fields(@course)
    @course.instructor_id = session[:user].id
    begin
      @course.save!
      CourseNode.create_course_node(@course)
      FileHelper.create_directory(@course)
      undo_link("The course \"#{@course.name}\" has been successfully created.")
      redirect_to controller: 'tree_display', action: 'list'
    rescue StandardError
      flash[:error] = $ERROR_INFO # "The following error occurred while saving the course: #"+
      redirect_to action: 'new'
    end
  end

  # delete the course
  def delete
    @course = Course.find(params[:id])
    begin
      FileHelper.delete_directory(@course)
    rescue StandardError
      flash[:error] = $ERROR_INFO
    end
    @course.destroy
    undo_link("The course \"#{@course.name}\" has been successfully deleted.")
    redirect_to controller: 'tree_display', action: 'list'
  end

  # Displays all the teaching assistants for a course
  def view_teaching_assistants
    @course = Course.find(params[:id])
    @ta_mappings = @course.ta_mappings
  end

  # Adds a teaching assistant to a course
  def add_ta
    @course = Course.find(params[:course_id])
    @user = User.find_by(name: params[:user][:name])
    if @user.nil?
      flash.now[:error] = 'The user inputted "' + params[:user][:name] + '" does not exist.'
    elsif !TaMapping.where(ta_id: @user.id, course_id: @course.id).empty?
      flash.now[:error] = 'The user inputted "' + params[:user][:name] + '" is already a TA for this course.'
    else
      @ta_mapping = TaMapping.create(ta_id: @user.id, course_id: @course.id)
      @user.role = Role.find_by name: 'Teaching Assistant'
      @user.save

      @course = @ta_mapping
      undo_link("The TA \"#{@user.name}\" has been successfully added.")
    end
    render action: 'add_ta.js.erb', layout: false
  end

  # Remove a teaching assistant from a course
  def remove_ta
    @ta_mapping = TaMapping.find(params[:id])
    @ta = User.find(@ta_mapping.ta_id)

    # if the user does not have any other TA mappings, then the role should be changed to student
    other_ta_mappings_num = TaMapping.where(ta_id: @ta_mapping.ta_id).size - 1
    if other_ta_mappings_num.zero?
      @ta.role = Role.find_by name: 'Student'
      @ta.save
    end
    @ta_mapping.destroy

    @course = @ta_mapping
    undo_link("The TA \"#{@ta.name}\" has been successfully removed.")

    render action: 'remove_ta.js.erb', layout: false
  end

  # This method is called in the update and create methods to set the fields of a course
  def set_course_fields(_course)
    @course.name = params[:course][:name]
    @course.institutions_id = params[:course][:institutions_id]
    @course.directory_path = params[:course][:directory_path]
    @course.info = params[:course][:info]
    @course.private = params[:course][:private].nil? ? 0 : params[:course][:private]
    @course.locale = params[:course][:locale]
  end
end
