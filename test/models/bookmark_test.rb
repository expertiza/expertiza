require 'test_helper'

class BookmarkTest < ActiveSupport::TestCase

  def setup
    #Bookmark(id: , url: , discoverer_user_id: , user_count:, )
    @existing_bookmark = bookmarks(:existing_bookmark)
    @user2 = users(:user2) 


    # @existing_bookmark = Bookmark.new(b_url: 'example_url.com', b_title: 'First Bookmark' , b_tags_text: 'expertiza' , 
    #                           b_description: 'this is a desc of first bookmark',
    #                           session_user: 'user2', topic_id: '1')
    #bmapping1
    #@existing_bookmark = Bookmark.new(id: 1 , url: 'www.sample_url.com', discoverer_user_id: 2, user_count: 1)
  
  end

  test "add_this_bookmark edits an existing bookmark" do
    assert (@existing_bookmark.bmappings[0].title.eql?("Bmapping1")) # ensure @existing_bookmark is still available
    #bookmark already exists so it should get edited
    Bookmark.add_this_bookmark('www.sample.com', 'Modified Existing Bookmark' , 'expertiza' , 
                              'this is a desc of first bookmark', @user2, '1')
    assert (Bookmark.find_by_id(1).bmappings[0].title.eql?("Modified Existing Bookmark"))
    
  end    

  # test "add_this bookmark creates a new bookmark without topic_id" do
    @new_bookmark = Bookmark.add_this_bookmark('example_url.com', 'New Bookmark' , 'expertiza' , 
                               'this is a desc of new bookmark','user2') # topic_id not passed (should be set to nil)

    assert_equals @new_bookmark.topic_id, nil

    Bookmark.add_this_bookmark('www.some_other_sample.com', 'New Bookmark' , 'expertiza' , 
                              'this is a desc of new bookmark', @user2)

    assert (Bookmark.find_by_id(1).bmappings[1].title.eql?("New Bookmark"))
    
    
  end

  # test "add_this_bookmark creates a new bookmark with topic_id" do
  #   @new_bookmark = Bookmark.add_this_bookmark(b_url: 'example_url.com', b_title: 'New Bookmark' , b_tags_text: 'expertiza' , 
  #                             b_description: 'this is a desc of new bookmark',
  #                             session_user: 'user2', topic_id: '2') 
  #   assert_equals @new_bookmark.topic_id, '2'
  # end

  # test "search_alltags_allusers returns all the bookmarks from all the users" do
  #   order_by = "most_recent"
  #   array = Array.new
  #   array = Bookmark.search_alltags_allusers(order_by)
  #   # each element of result_array is a hash with elements    
  #   assert_equals @existing_bookmark.b_title, array[0][:title]
  # end

  # test "search_fortags_allusers returns no bookmarks because the tag is not matching" do
  #   order_by = "most_recent"
  #   tags_array = ["something_else"]
  #   array = Array.new
  #   array = Bookmark.search_fortags_allusers(tags_array, order_by)
  #   # each element of result_array is a hash with elements    
  #   assert (array.empty?)
  # end


end