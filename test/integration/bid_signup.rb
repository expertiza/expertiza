require 'test_helper'

class BidSignUp < ActionDispatch::IntegrationTest
  fixtures :users, :roles, :teams, :assignments, :nodes, :system_settings, :content_pages, :permissions, :participants
  fixtures :roles_permissions, :controller_actions, :site_controllers, :menu_items, :bids, :sign_up_topics, :teams_users
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end