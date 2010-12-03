require 'test_helper'

class UserTest < Test::Unit::TestCase
  
  # Test user retrieval by email
  def test_get_by_login_email
    user = User.get_by_login('ajbudlon@ncsu.edu')    
    assert_equal 'ajbudlon', user.name
  end
  
  # Test user retrieval by name
  def test_get_by_login_name
    user = User.get_by_login('ajbudlon@ncsu.edu')    
    assert_equal 'ajbudlon', user.name
  end

  # 101 add a new user 
  def test_add_user
    user = User.new(:name => "testStudent1",
                    :password => Digest::SHA1.hexdigest("test"),
                    :fullname => "test Student 1",
                    :role_id => "1")
    assert user.save
  end 
  
  # 102 Add a user with existing name 
  def test_add_user_with_exist_name
    user = User.new(:name => users(:admin1).name,
                    :password => Digest::SHA1.hexdigest("test"),
                    :fullname => "test admin 1",
                    :role_id => "3")
    assert !user.save
    assert_equal I18n.translate('activerecord.errors.messages')[:taken], user.errors.on(:name)
  end
  
  # 103 Check valid user name and password   
  def test_add_user_with_invalid_name
    user = User.new
    assert !user.valid?
    assert user.errors.invalid?(:name)
    #assert user.errors.invalid?(:password)
  end
  # 202 edit a user name to an invalid name (e.g. blank)
  def test_update_user_with_invalid_name
    user = users(:test1)
    user.name = "";
    assert !user.valid?
  end
  # 203 Change a user name to an existing name.
  def test_update_user_with_existing_name
    user = users(:test1)
    user.name = users(:admin1).name;
    assert !user.valid?
  end  
end
