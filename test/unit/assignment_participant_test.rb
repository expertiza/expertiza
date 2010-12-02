require File.dirname(__FILE__) + '/../test_helper'
require 'assignment_participant'

class AssignmentParticipantTest < Test::Unit::TestCase
  fixtures :assignments, :users, :roles
  
  def test_import
    row = Array.new
    row[0] = "student1"
    row[1] = "student1_fullname"
    row[2] = "student1@foo.edu"
    row[3] = "s1"
    
    @request    = ActionController::TestRequest.new
    @request.session[:user] = User.find( users(:student1).id )
    roleid = User.find(users(:student1).id).role_id
    Role.rebuild_cache
    Role.find(roleid).cache[:credentials]
    @request.session[:credentials] = Role.find(roleid).cache[:credentials]
    AuthController.set_current_role(roleid,@request.session)
    
    id = Assignment.find(assignments(:assignment_team_count).id).id
    
    pc = AssignmentParticipant.count
    AssignmentParticipant.import(row,@request.session,id)
    # verify that a single user was added to participants table
    assert_equal pc+1,AssignmentParticipant.count 
    user = User.find_by_name("student1")  
    # verify that correct user was added
    assert AssignmentParticipant.find_by_user_id(user.id)
  end
end 