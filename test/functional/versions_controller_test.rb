require 'test_helper'

class VersionsControllerTest < ActionController::TestCase

  test 'should get index redirect to versions_search' do
    get :index
    assert_redirected_to versions_search_path
  end

end