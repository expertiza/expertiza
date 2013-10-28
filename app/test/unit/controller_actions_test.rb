require 'test_helper'

class ControllerActionTest < ActiveSupport::TestCase
  fixtures :controller_actions
  def test_truth
    assert true
  end
  
  def test_new_controller_action
    a = ControllerAction.new
    assert !a.valid?
    assert a.errors.invalid?(:name)
  end

  def test_uniqueness_of_name
     a = ControllerAction.new
    a.name = "name"
    assert a.save
    b = ControllerAction.new
    b.name = "name"
    assert !b.save
  end
  def test_permission
    a = ControllerAction.new
    assert a.permission_id==nil
    
  end
  #TODO The actions_allowed method does not check for nil parameters.
  #Add that validation and uncomment this test
  #def test_actions_allowed
    #  assert ControllerAction.actions_allowed(nil)
  #end
  
  def test_find_for_permission
    assert ControllerAction.find_for_permission(nil)
  end
end
