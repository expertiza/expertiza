require File.dirname(__FILE__) + '/../test_helper'
require 'review_mapping_controller'

# Re-raise errors caught by the controller.
class ReviewMappingController; def rescue_action(e) raise e end; end

class ReviewMappingControllerTest < ActionController::TestCase

  fixtures :all

  def setup
    @controller = ReviewMappingController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @request.session[:user] = User.find(users(:admin).id )
    roleid = User.find(users(:admin).id).role_id
    Role.rebuild_cache

    Role.find(roleid).cache[:credentials]
    @request.session[:credentials] = Role.find(roleid).cache[:credentials]
    @request.session[:credentials] = nil if @request.session[:credentials].is_a? YAML::Object
    @settings = SystemSettings.find(:first)

    AuthController.set_current_role(roleid,@request.session)
  end

   def test_delete_reviewer
    id = ResponseMap.first(:conditions => {:reviewer_id => Fixtures.identify(:par2)}).id

    post :delete_reviewer, {:id => Fixtures.identify(:response_maps0)} , session_for(users(:admin))

    assert_redirected_to :action => 'list_mappings'
    assert_raise(ActiveRecord::RecordNotFound){ ResponseMap.find(:id) }
   end

  def test_add_reviewer
    number_of_responses = ResponseMap.count

    assign_id = Fixtures.identify(:assignment7)
    contributor_id = Participant.first(:conditions => {:parent_id => assign_id}).id
    user_id = Participant.last(:conditions => {:parent_id => assign_id}).user_id

    post :add_reviewer, {:id => assign_id, :contributor_id => contributor_id, :user_id => user_id }, session_for(users(:admin))

    assert_equal number_of_responses+1, ResponseMap.count
    assert_redirected_to :action => 'list_mappings'
  end

  def test_add_metareviewer
    number_of_responses = ResponseMap.count

    mapping = ResponseMap.find(Fixtures.identify(:response_maps3))
    mapping_id = mapping.id
    user_id = Participant.first(:conditions => ["id != ? and parent_id = ?", mapping.reviewee_id, mapping.assignment.id]).user_id

    post :add_metareviewer, {:id => mapping_id, :user_id => user_id }, session_for(users(:admin))

    assert_equal number_of_responses+1, ResponseMap.count
    assert_redirected_to :action => 'list_mappings'
  end

  def test_delete_all_reviewers
    assign_id = Fixtures.identify(:assignment7)
    contributor = Participant.first(:conditions => {:parent_id => assign_id})
    contributor_id = contributor.id

    number_of_responses = ResponseMap.count
    deleted_count = ParticipantReviewResponseMap.find(:all, :conditions => {:reviewed_object_id => assign_id, :reviewee_id => contributor_id}).count

    post :delete_all_reviewers, {:id => assign_id, :contributor_id => contributor_id, :force => true }, session_for(users(:admin))

    assert_equal number_of_responses-deleted_count, ResponseMap.count
    assert_redirected_to :action => 'list_mappings'
    assert_equal "All review mappings for \""+contributor.name+"\" have been deleted.", flash[:note]
  end

  def test_delete_all_metareviewers
    mapping = ResponseMap.find(Fixtures.identify(:response_maps3))
    mapping_id = mapping.id

    number_of_responses = ResponseMap.count
    deleted_count = MetareviewResponseMap.find(:all, :conditions => {:reviewed_object_id => mapping_id}).count
    post :delete_all_metareviewers, {:id => mapping_id, :force => true }, session_for(users(:admin))

    assert_equal number_of_responses-deleted_count, ResponseMap.count
    assert_redirected_to :action => 'list_mappings'
    assert_equal "All metareview mappings for contributor \""+mapping.reviewee.name+"\" and reviewer \""+mapping.reviewer.name+"\" have been deleted.", flash[:note]
  end

  def test_delete_all_reviewers_and_metareviewers
    assign_id = Fixtures.identify(:assignment7)

    deleted_count = ResponseMap.find(:all, :conditions => {:reviewed_object_id => assign_id}).count

    post :delete_all_reviewers_and_metareviewers, {:id => assign_id, :force => true }, session_for(users(:admin))

    assert_redirected_to :action => 'list_mappings'
    assert_equal "All review mappings for this assignment have been deleted.", flash[:note]
  end

  def test_search_by_reviewer
    assign_id = Fixtures.identify(:assignment7)
    user = Participant.first(:conditions => {:parent_id => assign_id})

    post :search_by_reviewer, {:id => assign_id, :user => {:fullname => user.fullname}}, session_for(users(:admin))

    assert_template :review_report
  end

  def test_get_questionnaire_id
    @assignment = Fixtures.identify(:assignment7)

    id = @assignment.get_review_questionnaire_id()

    assert(id.to_int > 0)
  end

end