require File.dirname(__FILE__) + '/../test_helper'
require 'yaml'
require 'assignment_participant'

class AssignmentParticipantTest < ActiveSupport::TestCase
  fixtures :assignments, :users, :roles, :participants
  
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
  
  def test_publishing_rights
    participants = [ participants(:par0), participants(:par1) ]
    private_key = users(:student1).generate_keys
    
    AssignmentParticipant.grant_publishing_rights(private_key, participants)
    for participant in participants
      assert_not_nil participant.digital_signature
      assert_not_nil participant.time_stamp
      assert participant.permission_granted
      assert participant.verify_digital_signature(participant.digital_signature)
    end
  end

  def test_publishing_rights_regenerate_keys
    participants = [ participants(:par0), participants(:par1) ]
    private_key = users(:student1).generate_keys
    
    AssignmentParticipant.grant_publishing_rights(private_key, participants)

    # generate keys again, everything should be resigned automatically
    private_key = users(:student1).generate_keys
    
    for participant in participants
      assert_not_nil participant.digital_signature
      assert_not_nil participant.time_stamp
      assert participant.permission_granted
      assert participant.verify_digital_signature(participant.digital_signature)
    end
  end

  def test_publishing_rights_negative_tests
    participants = [ participants(:par0), participants(:par1) ]
    private_key = users(:student1).generate_keys
    
    AssignmentParticipant.grant_publishing_rights(private_key, participants)
    for participant in participants
      # try changing the time stamp and verify the digital signature is no longer valid
      saved_time_stamp = participant.time_stamp
      participant.time_stamp = (Time.now + 1).utc.strftime("%Y-%m-%d %H:%M:%S")
      assert !participant.verify_digital_signature(participant.digital_signature)
      
      # try changing the assignment name and verify the digital signature is no longer valid
      participant.time_stamp = saved_time_stamp
      saved_assignment_name = participant.assignment.name
      participant.assignment.name = "XXXX"
      assert !participant.verify_digital_signature(participant.digital_signature)
      participant.assignment.name = saved_assignment_name
    end
  end

  def test_submmit_first_hyperlink
    participant = participants(:par0)
    assert_nil participant.submitted_hyperlinks

    url = "http://www.ncsu.edu"
    participant.submmit_hyperlink(url)
    assert_not_nil participant.submitted_hyperlinks
    assert_equal YAML::dump([url]), participant.submitted_hyperlinks
  end

  def test_submit_third_hyperlink
    participant = participants(:par1)
    assert_not_nil participant.submitted_hyperlinks

    urls = YAML::load participant.submitted_hyperlinks
    assert_equal urls.size, 2
    
    url = "http://www.csc.ncsu.edu/"
    participant.submmit_hyperlink(url)

    urls = YAML::load participant.submitted_hyperlinks
    assert_equal urls.size, 3
    assert_equal url, urls[2]
  end

  def test_remove_second_hyperlink_of_three
    participant = participants(:par2)
    before_urls = YAML::load participant.submitted_hyperlinks
    assert_equal before_urls.size, 3
    
    participant.remove_hyperlink(1)
    after_urls = YAML::load participant.submitted_hyperlinks
    
    assert_equal after_urls.size, 2
    assert_equal before_urls[0], after_urls[0]
    assert_equal before_urls[2], after_urls[1]
  end

  def test_remove_one_hyperlink_of_one
    participant = participants(:par3)
    before_urls = YAML::load participant.submitted_hyperlinks
    assert_equal before_urls.size, 1
    
    participant.remove_hyperlink(0)
    assert_nil participant.submitted_hyperlinks
  end

  def test_reject_remove_nonexistent_index
    participant = participants(:par0)
    assert_raise RuntimeError do
      participant.remove_hyperlink(0)
    end
  end

  def test_reject_empty_hyperlink
    participant = participants(:par1)
    assert_raise RuntimeError do
      participant.submmit_hyperlink ""
    end
  end

end
