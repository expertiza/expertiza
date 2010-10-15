require File.dirname(__FILE__) + '/../test_helper'
require 'assignment_participant'

class AssignmentParticipantTest < Test::Unit::TestCase
  fixtures :assignments, :users
  
  def test_import
    row = Array.new
    row[0] = "s1"
    row[1] = "Student, One"
    row[2] = "one.student@blah.foo"
    row[3] = "s1"
    
    session = Hash.new
    session[:user] = users(:superadmin)
    
    id = assignments(:first).id
    
    pc = AssignmentParticipant.count
    AssignmentParticipant.import(row,session,id)
    # verify that a single user was added to participants table
    assert_equal pc+1,AssignmentParticipant.count 
    user = User.find_by_name("s1")
    # verify that correct user was added
    assert AssignmentParticipant.find_by_user_id(user.id)
  end
end 