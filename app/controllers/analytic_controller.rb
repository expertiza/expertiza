class AnalyticController < ApplicationController
  include CourseHelper
  include AnalyticHelper

  before_filter :init

  def init
    #all internal not use by the page
    @available_scope_types = [:courses, :assignments, :teams]
    @selected_scope_type = nil

    @available_graph_types = [:line, :bar, :pie, :scatter]
    @selected_graph_type = nil

    @available_courses = associated_courses(session[:user])
    @selected_courses = Array.new

    @analytic_module = Hash.new
    @analytic_module[:course] = CourseAnalytic
    @analytic_module[:assignment] = AssignmentAnalytic
    @analytic_module[:team] = AssignmentTeamAnalytic

    @selected_graph_data = Array.new

  end

  def index



  end

  def graph_data_type_list
    respond_to do |format|
      format.json { render :json => @analytic_module[params[:scope].to_sym].instance_methods}
    end
  end

  #dataPoint = [
  #    {:name => 'review 1', :data => [9.9, 7.5, 6.4, 9.2, 4.0, 6.0, 5.6, 8.5, 6.4, 4.1, 5.6, 4.4]},
  #    {:name => 'review 2', :data =>  [3.6, 8.8, 8.5, 3.4, 6.0, 4.5, 5.0, 4.3, 9.2, 8.5, 6.6, 9.3]},
  #    {:name => 'review 3', :data => [8.9, 8.8, 9.3, 4.4, 7.0, 8.3, 9.0, 9.6, 5.4, 6.2, 9.3, 5.2]}
  #]
  #options2 = {
  #    :title => "this is title2",
  #    :x_axis_categories => [ 'Problem1', 'Problem2', 'Problem3', 'Problem4', 'Problem5', 'Problem6', 'Problem7', 'Problem8', 'Problem9', 'Problem10', 'Problem11','Problem12']
  #}
  #Chart.new(:bar, dataPoint, options2)
  def get_graph_data_bundle
    data_point = Array.new
    params[:id].each do |object_id|
      object = Object.const_get(params[:scope].capitalize).find(object_id)
      object_data = Hash.new
      object_data[:name] = object.name
      object_data[:data] = gather_data(object, params[:data_type])
      data_point << object_data
    end
    option = Hash.new
    option[:x_axis_categories] = params[:data_type]

    respond_to do |format|
      format.json { render :json => Chart.new(:bar, data_point, option).data }
    end
  end



  def gather_data(object, data_type_array)
    data_array = Array.new
    data_type_array.each do |data_method|
      data_array << object.send(data_method)
    end
    data_array
  end

  def course_list
    courses = associated_courses(session[:user])
    course_list = Array.new
    courses.each do |course|
      course_list << [course.name, course.id]
    end
    respond_to do |format|
      format.json { render :json => sort_by_name(course_list) }
    end
  end

  def assignment_list
    course = Course.find(params[:course_id])
    assignments = course.assignments
    assignment_list = Array.new
    assignments.each do |assignment|
      assignment_list << [assignment.name, assignment.id]
    end
    respond_to do |format|
      format.json { render :json => sort_by_name(assignment_list) }
    end
  end

  def team_list
    assignment = Assignment.find(params[:assignment_id])
    teams = assignment.teams
    team_list = Array.new
    teams.each do |team|
      team_list << [team.name, team.id]
    end
    respond_to do |format|
      format.json { render :json => sort_by_name(team_list) }
    end
  end


end