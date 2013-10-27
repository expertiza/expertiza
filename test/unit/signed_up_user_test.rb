require File.dirname(__FILE__) + '/../test_helper'

class SignedUpUserTest < ActiveSupport::TestCase
  def new_signedup_user(attributes={})
    attributes[:topic_id] ||= 2345
    attributes[:creator_id]||= 1234
    attributes[:is_waitlisted]||= false
    attributes[:preference_priority_number]||= 1

    signed_up_user=SignedUpUser.new(attributes)
    signed_up_user.valid?
    signed_up_user
  end

  #test "should not be empty" do
  #   assert new_signedup_user.valid?
  #end

  #the values inserted in the table above are invalid since the topic id and creator id are invalid
  def test_valid
    assert_equal false, new_signedup_user.valid?
  end

  def test_topic_id
    assert_equal "can't be blank", new_signedup_user(:topic_id => '').errors[:topic_id]
  end

  def test_creator_id
    assert_equal "can't be blank", new_signedup_user(:creator_id => '').errors[:creator_id]
  end

  def test_is_waitlisted
  assert_equal "can't be blank", new_signedup_user(:is_waitlisted => '').errors[:is_waitlisted]
  end

  def test_pref_priority_number
    assert_blank new_signedup_user(:preference_priority_number => '').errors[:preference_priority_number]
  end
end