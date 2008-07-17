class CourseController < ApplicationController
  auto_complete_for :user, :name
  require 'ftools'
 
  def new    
  end

  def create
    course = Course.new(params[:course])
    course.instructor_id = session[:user].id
    course.save
    CourseNode.create(:node_object_id => course.id)
    begin
      File.makedirs(RAILS_ROOT + "/pg_data/" + params[:course][:directory_path])
    rescue
      flash[:error] = "An error was encountered while creating this course: "+$!
    end      
    
    redirect_to :controller => 'tree_display', :action => 'list'    
  end
  
  def delete
    course = Course.find(params[:id])
    begin
      entries = Dir.entries(RAILS_ROOT + "/pg_data/" + course.directory_path)    
      if Dir.entries(RAILS_ROOT + "/pg_data/" + course.directory_path).size == 2
         Dir.delete(RAILS_ROOT + "/pg_data/" + course.directory_path)          
      end  
    rescue
      flash[:error] = "An error was encountered while deleting the course: "+$!
    end
    
    CourseNode.find_by_node_object_id(course.id).destroy
    course.destroy
    
    redirect_to :controller => 'tree_display', :action => 'list'
   
   end
 
end