require 'test_helper'

class BookmarksTest < ActionDispatch::IntegrationTest

  # setup a user through fixtures first (check out fixtures/users.yml) then run the test
  def setup
    @user = users(:user2) # get a value from fixture named 'users' which has a symbol 
   end

  # test "login and access bookmarks/managing_bookmarks" do
  #   get 'home'
  #   assert_select "a[href=?]", '/password_retrieval/forgotten' # ensure you're on home page
  #   post '/auth/login', login: { name: @user.name, password: "123"} # log in user2 
  #   follow_redirect!
  #   #assert_template 'tree_display/list'  

  #   assert_template partial: '_login'
  #   get '/bookmarks/managing_bookmarks'
  #   assert_template  'bookmarks/managing_bookmarks', "ERROR +++++++++++"
  # end



end
