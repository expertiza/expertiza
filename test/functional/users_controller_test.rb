require File.dirname(__FILE__) + '/../test_helper'

require 'user_controller'
class UserControllerTest < ActionController::TestCase


test "should save institution id" do
  institutionID = institution_id.new
  assert institution_id.save, 'Institution ID saved'
end

test "should create instituition id" do
  assert_difference('User.count') do
    post :create, admin: {institution: 'North Carolina State Univeristy'}
  end
 
end