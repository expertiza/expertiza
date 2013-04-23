require File.dirname(__FILE__) + '/../test_helper'
require 'grades_controller'
require "lib/hamer.rb"

# Re-raise errors caught by the controller.
class GradesController; def rescue_action(e) raise e end; end

class GradesControllerTest < ActionController::TestCase
  include Hamer
  fixtures :participants, :deadline_types, :due_dates, :assignments, :roles
  set_fixture_class :system_settings => 'SystemSettings'
  fixtures :system_settings, :content_pages, :users, :due_dates
  @settings = SystemSettings.find(:first)
  
  def setup
    @controller = GradesController.new    
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @request.session[:user] = User.find(users(:admin).id ) 
    roleid = User.find(users(:admin).id).role_id 
    Role.rebuild_cache

    Role.find(roleid).cache[:credentials] 
    @request.session[:credentials] = Role.find(roleid).cache[:credentials]
    # Work around a bug that causes session[:credentials] to become a YAML Object
    @request.session[:credentials] = nil if @request.session[:credentials].is_a? YAML::Object
    @settings = SystemSettings.find(:first)    
    AuthController.set_current_role(roleid,@request.session) 
  end
  
  def test_update 
    post :update, :id => participants(:par1).id, :participant => {:grade => '95'}, :total_score => 100
    participant = AssignmentParticipant.find(participants(:par1).id)    
#   assert_equal 95,participants(:par1).grade
    assert_equal 95,participant.grade
  end
  
  def test_view
    sample_assignment = assignments(:assignment_project1)
    assert_recognizes({:controller => 'grades', :action => 'view'}, {:path => 'grades/view'})
    assert_valid(sample_assignment)
    test_reviewers = get_reviewer_objects(sample_assignment.users)
    test_submissions = get_submission_objects(sample_assignment.participants)
    assert_not_nil(test_reviewers)
    assert_not_nil(test_submissions)

     #Need to test the return value of  Hamer.calculate_weighted_scores_and_reputation() but the function
    #does not check for the posibility of number of reviews being 0 for an assignment.
    #Nil check may be absent in other places too.
    #test_evaluated_submissions = Hamer.calculate_weighted_scores_and_reputation(test_submissions, test_reviewers)[:submissions]
    #assert_not_nil(test_evaluated_submissions)
    post :view, :id => sample_assignment.id
    assert_response(:redirect)
  end
  
end