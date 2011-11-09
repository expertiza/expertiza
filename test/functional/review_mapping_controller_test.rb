require File.dirname(__FILE__) + '/../test_helper'
require 'review_mapping_controller'

# Re-raise errors caught by the controller.
class ReviewMappingController; def rescue_action(e) raise e end; end

class ReviewMappingController < ActionController::TestCase
  # use dynamic fixtures to populate users table
  # for the use of testing
  fixtures :users
  fixtures :assignments
  fixtures :questionnaires
  fixtures :courses
  set_fixture_class :system_settings => 'SystemSettings'
  fixtures :system_settings
  fixtures :content_pages
  @settings = SystemSettings.find(:first)

  def setup
    @controller = ReviewMappingController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @request.session[:user] = User.find(users(:instructor3).id )
    roleid = User.find(users(:instructor3).id).role_id
    Role.rebuild_cache

    Role.find(roleid).cache[:credentials]
    @request.session[:credentials] = Role.find(roleid).cache[:credentials]
    # Work around a bug that causes session[:credentials] to become a YAML Object
    @request.session[:credentials] = nil if @request.session[:credentials].is_a? YAML::Object
    @settings = SystemSettings.find(:first)
    AuthController.set_current_role(roleid,@request.session)
    #   @request.session[:user] = User.find_by_name("suadmin")
  end


 def select_reviewer
   @assignment = Assignment.first
   id = @assignment.id
   contributor = id.get_contributor(params[:contributor_id])
    session[:contributor] = contributor
   post :select_reviewer, {:assignment_id => 20698453,:contributor_id => 360832179}
 end

  def add_reviewer
    @assignment = Assignment.first
   id = @assignment.id
    reviewer_id = session[:user].id
    post :assign_reviewer_dynamically,{:assignment_id => 20698453,:reviewer_id => 360832179}
  end

  def assign_reviewer_dynamically
    @assignment = Assignment.first
   id = @assignment.id
    reviewer_id = session[:user].id
    post :assign_reviewer_dynamically,{:assignment_id => 20698453,:reviewer_id => 360832179, :i_dont_care => true}
  end

  def assign_metareviewer_dynamically
     @assignment = Assignment.first
   id = @assignment.id
    reviewer_id = AssignmentParticipant.find_by_parent_id(id)
    post :assign_metareviewer_dynamically,{:assignment_id => id,:metareviewer_id => reviewer_id}
    assert_redirected_to :controller => 'student_review', :action => 'list', :id => metareviewer_id
  end

end







