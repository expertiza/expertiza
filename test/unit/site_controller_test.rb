require File.dirname(__FILE__) + '/../test_helper'

class SiteControllerTest < ActiveSupport::TestCase

  fixtures :site_controllers, :permissions, :controller_actions
  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # Do nothing
    @sitecontroller = SiteController.new
  end

   def test_permission
     @permission = Permission.find_by_id(site_controllers(:site_controller_permissions).permission_id)
      assert_equal "administer goldberg", @permission.name
   end

   def test_actions
      assert_raises(ActiveRecord::StatementInvalid) {@sitecontroller.actions}

   end


end