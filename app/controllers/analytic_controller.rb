class AnalyticController < ApplicationController
  include CourseHelper
  include AnalyticHelper

  before_filter :init
  # List of supported data fields used by all charts (when enabled). Currently pulled from Bar chart. 
  # To do: Confirm if Pie charts and Line graphs support the entire same set. If not, eliminate the rest
  def generic_supported_types
    [
      #general
      "num_participants",
      "num_assignments",
      "num_teams",
      "num_reviews",
      #assignment_teams
      "total_num_assignment_teams",
      "average_num_assignment_teams",
      "max_num_assignment_teams",
      "min_num_assignment_teams",
      #assignment_scores
      "average_assignment_score",
      "max_assignment_score",
      "min_assignment_score",
      #assignment_reviews
      "total_num_assignment_reviews",
      "average_num_assignment_reviews",
      "max_num_assignment_reviews",
      "min_num_assignment_reviews",
      #team_reviews
      "total_num_team_reviews",
      "average_num_team_reviews",
      "max_num_team_reviews",
      "min_num_team_reviews",
      #team_scores
      "average_team_score",
      "max_team_score",
      "min_team_score",
      #review_score
      "average_review_score",
      "max_review_score",
      "min_review_score",
      #review_word_count
      "total_review_word_count",
      "average_review_word_count",
      "max_review_word_count",
      "min_review_word_count",
      #character_count
      "total_review_character_count",
      "average_review_character_count",
      "max_review_character_count",
      "min_review_character_count"
    ]
  end

  def index

  end
  def init
    #all internal not use by the page
    @available_scope_types = [:courses, :assignments, :teams]
    @available_graph_types = [:line, :bar, :pie, :scatter]
    @available_courses = associated_courses(session[:user])

    #Hash of available method name of the data mining methods with different type of selection
    @available_data_types = Hash.new
    #data type by scope
    @available_data_types[:course] = CourseAnalytic.instance_methods
    @available_data_types[:assignment] = AssignmentAnalytic.instance_methods
    @available_data_types[:team] = AssignmentTeamAnalytic.instance_methods
    #data type by chart type
    @available_data_types[:bar] = generic_supported_types
    @available_data_types[:scatter] = []
    # Linking the supportd data types to pie chart and line graph so that they can be generated
    @available_data_types[:line] = generic_supported_types
    @available_data_types[:pie] = generic_supported_types
  end

  def graph_data_type_list
    #cross checking @available_data_type[chart_type] with @available_data_type[scope]
    data_type_list =  @available_data_types[params[:scope].to_sym] & (@available_data_types[params[:type].to_sym].map &:to_sym)
    data_type_list.sort!
    respond_to do |format|
      format.json { render :json => data_type_list}
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
  #should be rename to graph_data_packet
  def get_graph_data_bundle
    if params[:id].nil? or params[:data_type].nil?
      respond_to do |format|
        format.json { render :json => nil }
      end
      return
    end
   # removed conditional statemets to use one generic function to generate charts
    chart_data = get_chart_data(params[:type],params[:scope], params[:id], params[:data_type])

    respond_to do |format|
      format.json { render :json => chart_data }
    end
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

  def render_sample

  end


end
