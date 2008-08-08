# Provides Course functions
# Author: unknown
#
# Last modified: 7/18/2008
# By: ajbudlon
class CourseController < ApplicationController
  auto_complete_for :user, :name
  require 'fileutils'
 
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
    course = Course.find(params[:id])
    if course.directory_path != params[:course][:directory_path]
      begin
        FileHelper.delete_directory(course.directory_path)
      rescue
        flash[:error] = $!
      end
      
      begin
        FileHelper.create_directory(params[:course][:directory_path])
      rescue
        flash[:error] = $!
      end
    end      
    course.update_attributes(params[:course])   
    redirect_to :controller => 'tree_display', :action => 'list'
  end
  
  def copy    
    orig_course = Course.find(params[:id])
    new_course = orig_course.clone
    new_course.instructor_id = session[:user].id
    new_course.name = 'Copy of '+orig_course.name
    begin
     new_course.save!
     new_course.create_node
     flash[:note] = 'The course is currently associated with an existing location. This could cause errors for furture submissions.'      
     redirect_to :controller => 'course', :action => 'edit', :id => new_course.id
    rescue
     flash[:error] = 'The course was not able to be copied: '+$!
     redirect_to :controller => 'tree_display', :action => 'list' 
    end      
  end

  def create
    course = Course.new(params[:course])
    course.instructor_id = session[:user].id
    begin
      course.save!
      course.create_node
      FileHelper.create_directory(course.directory_path) 
      redirect_to :controller => 'tree_display', :action => 'list'
    rescue
      flash[:error] = "An error occurred while saving the course: "+$!
      redirect_to :action => 'new'
    end        
  end
  
  def delete
    course = Course.find(params[:id])
    begin
      FileHelper.delete_directory(course.directory_path)
    rescue
      flash[:error] = $!
    end
    CourseNode.find_by_node_object_id(course.id).destroy
    course.destroy    
    redirect_to :controller => 'tree_display', :action => 'list'   
  end
  
  def toggle_access
    course = Course.find(params[:id])
    course.private = !course.private
    begin
      course.save!
    rescue
      flash[:error] = $!
    end
    redirect_to :controller => 'tree_display', :action => 'list'
  end
end