require File.dirname(__FILE__) + '/../test_helper'

class DeadlineRightTest < ActiveSupport::TestCase
  fixtures :deadline_rights

  # Replace this with your real tests.
  def test_create_deadline_right
    @deadline_right1 = DeadlineRight.new
    @deadline_right1.name= "Late"
    assert @deadline_right1.save
  end

  def test_update_deadline_right
    @deadline_right1 = DeadlineRight.find(deadline_rights(:last).id)
    @deadline_right1.name= "Late"
    @deadline_right1.save
    @deadline_right1.reload
    assert_equal "Late", @deadline_right1.name
  end

  def test_delete_deadline_right
    @deadline_right1 = DeadlineRight.new
    @deadline_right1.name= "Late"
    @deadline_right1.save
    @deadline_right1.delete
    begin
      @deadline_right1 = DeadlineRight.find(@deadline_right1.id)
    rescue
      assert true
      return
    end
    assert false
    return
  end

  def test_deadline_right_name
    deadline_right = DeadlineRight.create(name: "aaaaabbbbbaaaaabbbbbaaaaabbbbbaaaaa")
    assert !deadline_right.valid?
  end

end
