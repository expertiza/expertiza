require 'test_helper'

class BookmarksTest < ActionDispatch::IntegrationTest

  # setup a user through fixtures first (check out fixtures/users.yml) then run the test
  def setup
    @user = users(:user2) # get a value from fixture named 'users' which has a symbol 'michael' defined
  end


  test "accessing bookmarks/managing_bookmarks" do
    get 'bookmarks/managing_bookmarks'
    assert_template 'bookmarks/managing_bookmarks'
  end



end
