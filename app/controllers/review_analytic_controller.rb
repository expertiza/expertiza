class ReviewAnalyticController < ApplicationController
  include CourseHelper

  def index

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