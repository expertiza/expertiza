class AnalyticController < ApplicationController
  include CourseHelper

  before_filter :init
  @available_scope_types
  @selected_scope_type

  @available_graph_types
  @selected_graph_type

  @available_courses
  @selected_courses

  @available_graph_data
  @selected_graph_data

  def index
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
    course_list
  end

  def assignment_list(course)
    assignments = course.assignments
    assignment_list = Array.new
    assignments.each do |assignment|
      assignment_list << [assignment.name, assignment.id]
    end
    assignment_list
  end

  def team_list(assignment)
    teams = assignment.teams
    team_list = Array.new
    teams.each do |team|
      team_list << [team.name, team.id]
    end
    team_list
  end


end