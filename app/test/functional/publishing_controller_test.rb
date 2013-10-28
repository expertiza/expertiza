require File.dirname(__FILE__) + '/../test_helper'
require 'publishing_controller'

# Re-raise errors caught by the controller.
class PublishingController; def rescue_action(e) raise e end; end

class PublishingControllerTest < ActionController::TestCase
  fixtures :users, :roles, :participants

  def setup
    @controller = PublishingController.new  
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @request.session[:user] = User.find(users(:student1).id)
    Role.rebuild_cache
    AuthController.set_current_role(User.find(users(:student1).id).role_id,@request.session)
  end
  
  def test_grant
    get :grant, :id => participants(:par0).id
    assert_template 'publishing/grant'
  end

  def test_grant_with_private_key
    user = users(:student1)
    private_key = user.generate_keys

    # grant publishing rights to each assignment individually
    participants = AssignmentParticipant.find_all_by_user_id(user.id)
    for participant in participants
      assert !participant.permission_granted
      post :grant_with_private_key, :id => participant.id, :private_key => private_key
      assert_response :redirect
      assert_redirected_to :action => 'view'
      par = AssignmentParticipant.find(participant.id)
      assert par.permission_granted
      assert par.verify_digital_signature(par.digital_signature)
    end
    
    # remove publishing rights from all of them now
    post :update_publish_permissions, :allow => '0'
    assert_response :redirect
    assert_redirected_to :action => 'view'

    participants = AssignmentParticipant.find_all_by_user_id(user.id)
    for participant in participants
      assert !participant.permission_granted
    end
  end

  def test_grant_with_private_key_invalid
    # try granting with an old private key
    user = users(:student1)
    private_key = user.generate_keys
    user.generate_keys
    post :grant_with_private_key, :id => participants(:par0).id, :private_key => private_key
    assert_response :redirect
    assert_redirected_to :controller => 'publishing', :action => 'grant', :id => participants(:par0).id
  end

  def test_set_publish_permission
    user = users(:student1)
    private_key = user.generate_keys

    # grant publishing rights to each assignment individually
    post :grant_with_private_key, :id => participants(:par0).id, :private_key => private_key
    participant = AssignmentParticipant.find(participants(:par0).id)
    assert participant.permission_granted
    
    post :set_publish_permission, :id => participants(:par0).id, :allow => '0'
    participant = AssignmentParticipant.find(participants(:par0).id)
    assert_response :redirect
    assert_redirected_to :action => 'view'
    assert !participant.permission_granted
  end

  def test_set_publish_permission_invalid
    post :set_publish_permission, :id => participants(:par0).id, :allow => '1'
    participant = AssignmentParticipant.find(participants(:par0).id)
    assert_response :redirect
    assert_redirected_to :action => 'grant'
    assert !participant.permission_granted
  end

  def update_publish_permission
    post :update_publish_permissions, :allow => '1'
    assert_response :redirect
    assert_redirected_to :action => 'grant'
  end
end

