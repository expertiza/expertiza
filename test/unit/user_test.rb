require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase
  fixtures :users
  
  def test_random_password_generation_for_new_users
    u = User.new(:email => "new@guy.co", :name => 'newguy')
    u.save!
    assert u.clear_password.present?
  end
  
  def test_no_random_password_generation_for_new_users_with_specified_password
    u = User.new(:email => "new@guy.co", :name => 'newguy', :clear_password => 'mypass', :clear_password_confirmation => 'mypass')
    u.save!
    assert_equal "mypass", u.clear_password
  end
  
  # 101 add a new user 
  def test_add_user
    user = User.new
    user.name = "testStudent1"
    user.fullname = "test_Student_1"
    user.clear_password = "testStudent1"
    user.clear_password_confirmation = "testStudent1"
    user.email = "testStudent1@foo.edu"
    user.role_id = "1"
    user.save! # an exception is thrown if the user is invalid
  end 
  
  # 102 Add a user with existing name 
  def test_add_user_with_exist_name
    user = User.new
    user.name = 'student1'
    user.clear_password = "testStudent1"
    user.clear_password_confirmation = "testStudent1"
    user.fullname = "student1_fullname",
    user.role_id = "3"
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
    user = User.find_by_login('student1')
    user.name = "";
    assert !user.valid?
  end
  # 203 Change a user name to an existing name.
  def test_update_user_with_existing_name
    user = User.find_by_login('student1')
    user.name = "student2"
    assert !user.valid?
  end  
  
  def test_generate_keys
    user = users(:student1)
    private_key = user.generate_keys
    assert_not_nil private_key
    assert_not_nil user.digital_certificate

    # verify that we can sign something using the private key and then decrypt it using the public key
    hash_data = Digest::SHA1.digest(Time.now.utc.strftime("%Y-%m-%d %H:%M:%S"))
    clear_text = decrypt(hash_data, private_key, user.digital_certificate)
    assert_equal hash_data, clear_text
    
    # try decrypting a signature made using an old private key
    user.generate_keys
    clear_text = decrypt(hash_data, private_key, user.digital_certificate)
    assert_not_equal hash_data, clear_text    
  end
  
  def decrypt(hash_data, private_key, digital_certificate)
    private_key2 = OpenSSL::PKey::RSA.new(private_key)
    cipher_text = Base64.encode64(private_key2.private_encrypt(hash_data))
    cert = OpenSSL::X509::Certificate.new(digital_certificate)
    public_key1 = cert.public_key 
    public_key = OpenSSL::PKey::RSA.new(public_key1)    
    begin
      clear_text = public_key.public_decrypt(Base64.decode64(cipher_text))
    rescue
      clear_text = ''
    end

    clear_text
  end

  def test_get_available_users
    # student1 should be available to instructor1 based on their roles
    avail_users_like_student1 = users(:instructor1).get_available_users('student1')
    assert_equal 1, avail_users_like_student1.size
    assert_equal "student1", avail_users_like_student1.first.name
  end
  
  def test_emails_must_be_valid
    u = User.new(:email => "new@guy.co", :name => 'newguy')
    assert u.valid?, "Should be valid with a valid email"
    
    u.email = "not@valid"
    assert !u.valid?, "Should not be valid with an invalid email"
  end
  
  def test_emails_need_not_be_unique
    used_email = users(:admin).email
    u = User.new(:email => used_email, :name => 'newguy')
    assert u.valid?, "User should be valid with a duplicate email"
  end

  def test_check_email
    user = User.new
    user.name = "testStudent1"
    user.fullname = "test_Student_1"
    user.clear_password = "testStudent1"
    user.clear_password_confirmation = "testStudent1"
    user.email = "testStudent1@foo.edu"
    user.role_id = "1"
    user.save! # an exception is thrown if the user is invalid

    email = MailerHelper::send_mail_to_user(user,"Test Email","user_welcome",user.clear_password)
    assert !ActionMailer::Base.deliveries.empty?         # Checks if the mail has been queued in the delivery queue

    assert_equal [user.email], email.to                  # Checks if the mail is being sent to proper user
    assert_equal "Test Email", email.subject             # Checks if the mail subject is the same

  end

end
