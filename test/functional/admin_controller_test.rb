require 'rails/all'
require 'app/controllers/admin_controller'

class AdminControllerTest < ActiveSupport::TestCase


    test 'should redirect to new administrator page' do
      get :new_administrator
      assert_redirected_to :controller => :users, :action => :new
    end

    test 'should create new admin' do
      get :new_administrator
      @admin = PgUsersController.new(:id => 2, :name => "admin1", :role_id => 5)
      @admin.save
      assert_response
    end

end

