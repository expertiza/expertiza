require File.dirname(__FILE__) + '/../test_helper'
require 'institution_controller'

# Re-raise errors caught by the controller.
class InstitutionController; def rescue_action(e) raise e end; end

class InstitutionsControllerTest < ActionController::TestCase
  fixtures :institutions
  fixtures :users, :roles
  def setup
    @controller = InstitutionController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:user] = User.find(users(:superadmin).id)
    Role.rebuild_cache
    AuthController.set_current_role(User.find(users(:superadmin).id).role_id,@request.session)
  end

  # 401 Add a new institution
  def test_add_institution_with_valid_name
    number_of_institution = Institution.count
    post :create, :institution => { :name => 'Biomedical Engineering'}
    assert_equal flash[:notice], 'Institution was successfully created.'
    assert_redirected_to :action => 'list'
    assert_equal Institution.count, number_of_institution+1
    assert Institution.find(:all, :conditions => "name = 'Biomedical Engineering'");
  end
  
  # 402 Add a new institution with invalid name (name='')
  def test_add_institution_with_invalid_name
    number_of_institution = Institution.count
    post :create, :institution => { :name => ''}
    assert_template 'institution/new'
    assert_equal number_of_institution, Institution.count
    assert Institution.find(:all, :conditions => "name = ''").count == 0;
  end
  
  # 403 Add a new institution with a name that already exists.
  def test_add_institution_with_duplicate_name
    number_of_institution = Institution.count
    assert_equal 1, Institution.count(:all, :conditions => "name = 'Test state university'");
    post :create, :institution => { :name => 'Test state university'}
    assert_template 'institution/new'
    assert_equal Institution.count, number_of_institution
    assert_equal 1, Institution.count(:all, :conditions => "name = 'Test state university'");
  end
  
  # 404 Edit the name of a institution
  def test_edit_institution_with_valid_name
    number_of_institution = Institution.count
    post :update,:id => institutions(:institution1).id, :institution => { :name => 'Biomedical Engineer'}
    assert_equal flash[:notice], 'Institution was successfully updated.'
    assert_redirected_to :action => 'show', :id => institutions(:institution1).id
    assert_equal Institution.count, number_of_institution
    assert_equal 1, Institution.count(:all, :conditions => "name = 'Biomedical Engineer'");
    assert Institution.find(:all, :conditions => "name = 'Computer Science'").count == 0;
  end

  # 405 Change the name of a institution to an invalid institution name (name='')
  def test_edit_institution_with_invalid_name
    number_of_institution = Institution.count
    post :update,:id => institutions(:institution0).id, :institution => { :name => ''}
    assert_equal Institution.count, number_of_institution
    assert Institution.find(:all, :conditions => "name = ''").count == 0;
  end
  
  # 406 Change the name of a institution to an existing institution name
  def test_edit_institution_with_duplicate_name
    number_of_institution = Institution.count
    post :update,:id => institutions(:institution0).id, :institution => { :name => institutions(:institution1).name}
    assert_equal Institution.count, number_of_institution
    assert_equal 1, Institution.count(:all, :conditions => "name = 'Test state university'");
    assert Institution.find(:all, :conditions => "name = 'Computer Science'").count == 0;
  end
  
  # 501 Delete a institution
  def test_delete_institution
    number_of_institution = Institution.count
    post :destroy,:id => institutions(:institution1)
    assert_redirected_to :action => 'list'
    assert_equal number_of_institution-1, Institution.count
    assert_raise(ActiveRecord::RecordNotFound){ Institution.find(1) }
  end






















end