class AnalyticController < ApplicationController
  include CourseHelper
  include AnalyticHelper

  def index
    #all internal not use by the page
    @available_scope_types = [:courses, :assignments, :teams]
    @selected_scope_type = nil

    @available_graph_types = [:line, :bar, :pie, :scatter]
    @selected_graph_type = nil

    @available_courses = associated_courses(session[:user])
    @selected_courses = Array.new

    @available_graph_data = Hash.new
    @available_graph_data[:course] = CourseAnalytic.instance_methods
    @available_graph_data[:assignment] = AssignmentAnalytic.instance_methods
    @available_graph_data[:team] = AssignmentTeamAnalytic.instance_methods
    @selected_graph_data = Array.new

  end


  def possible_comparison_types

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