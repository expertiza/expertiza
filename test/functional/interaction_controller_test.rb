require File.dirname(__FILE__) + '/../test_helper'
require 'interaction_controller'

class InteractionsControllerTest < ActionController::TestCase

  fixtures :users, :participants, :assignments, :wiki_types, :response_maps
  fixtures :roles
# --------------------------------------------------------------
  set_fixture_class :system_settings => 'SystemSettings'    
  fixtures :system_settings
  fixtures :content_pages

  @settings = SystemSettings.find(:first)
  
  def setup
    @controller = UsersController.new  
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @request.session[:user] = User.find(users(:admin).id )
    roleid = User.find(users(:admin).id).role_id
    Role.rebuild_cache

    Role.find(roleid).cache[:credentials] 
    @request.session[:credentials] = Role.find(roleid).cache[:credentials]
    # Work around a bug that causes session[:credentials] to become a YAML Object
    @request.session[:credentials] = nil if @request.session[:credentials].is_a? YAML::Object
    @settings = SystemSettings.find(:first)    
    AuthController.set_current_role(roleid,@request.session) 
    
    @testUser = users(:student1).id    
  end
  
  # 101 create new interaction
  def test_create_helper_interaction
    post :create, :assign => assignments(:assignment2).id,
        :type => "helper",
        :teams => teams(:Team2).name,
        :interaction => interactions(:HelperInteraction1),
        :comments => "deployment of project",
        :interaction_date => Time.new
    assert_equal flash[:notice], "Interaction reported successfully."
  end

  # 102 create same interaction
  def test_create_same_interaction
    post :create, :assign => assignments(:assignment2).id,
        :type => "helper",
        :teams => teams(:Team3).name,
        :interaction => interactions(:HelperInteraction1),
        :comments => "deployment of project",
        :interaction_date => Time.new
    assert_equal flash[:notice], :helper+" does not exist."
  end

  # 103 create new interaction with non existing helper
  def test_create_helpee_interaction
    post :create, :assign => assignments(:assignment2).id,
        :type => "helpee",
        :teams => teams(:Team3).name,
        :interaction => interactions(:HelpeeInteraction1),
        :comments => "deployment of project",
        :interaction_date => Time.new,
        :helper => "zoe",
        :score => 3
    assert_equal flash[:notice], ' Interaction already reported.'
  end

  # 104 create new interaction with non existing helper
  def test_create_non_existing_helper
    post :create, :assign => assignments(:assignment2).id,
        :type => "helpee",
        :teams => teams(:Team3).name,
        :interaction => interactions(:HelpeeInteraction1),
        :comments => "deployment of project",
        :interaction_date => Time.new,
        :helper => "abcd",
        :score => 3
    assert_equal flash[:notice], ' Interaction already reported.'
   end
end
