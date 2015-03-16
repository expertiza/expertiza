require 'test_helper'

class BookmarkTest < ActiveSupport::TestCase

  def setup
    #Bookmark(id: , url: , discoverer_user_id: , user_count:, )
    @existing_bookmark = bookmarks(:existing_bookmark)
    @user2 = users(:user2) 
  
  end

  # test "add_this_bookmark edits an existing bookmark" do
  #   assert (@existing_bookmark.bmappings[0].title.eql?("Bmapping1")) # ensure @existing_bookmark is still available
  #   #bookmark already exists so it should get edited
  #   Bookmark.add_this_bookmark('www.sample.com', 'Modified Existing Bookmark' , 'expertiza' , 
  #                             'this is a desc of first bookmark', @user2, '1')
  #   assert (Bookmark.find_by_id(1).bmappings[0].title.eql?("Modified Existing Bookmark"))
    
  # end    

  # test "add_this bookmark creates a new bookmark WITHOUT topic_id" do
  #   #Rails::logger.warn("TOTAL NUMBER OF BOOKMARKS: #{Bookmark.count}")
  #   assert (Bookmark.count == 1) # only bookmark from fixture present at this point
  #   Bookmark.add_this_bookmark('www.some_other_sample.com', 'New Bookmark' , 'expertiza' , 
  #                             'this is a desc of new bookmark', @user2, nil)
    
  #   assert (Bookmark.count == 2) # since url was different, new bookmark was added (now there is two)

  #   # initial bookmark has not been corrupted/edited
  #   assert (Bookmark.find_by_url('www.some_other_sample.com').bmappings[0].title.eql?("New Bookmark"))
  #   # newly created bookmark has a correct url
  #   assert (Bookmark.find_by_url('www.sample.com').bmappings[0].title.eql?("Bmapping1"))    

  # end

  test "add_this_bookmark creates a new bookmark WITH topic_id" do
    assert (Bookmark.count == 1) # only bookmark from fixture present at this point
    Bookmark.add_this_bookmark('www.some_other_sample.com', 'New Bookmark' , 'expertiza' , 
                              'this is a desc of new bookmark', @user2, 2)

    assert (Bookmark.count == 2) # since url was different, new bookmark was added (now there is two)
  end

  test "search_alltags_allusers returns all the bookmarks from all the users" do

    order_by = "most_recent"

    array = Array.new
    array = Bookmark.search_alltags_allusers(order_by)

    # each element of result_array is a hash with elements    
    assert (Bookmark.find_by_id(1).bmappings[0].title.eql?(array[0]["title"]))
  end

   test "search_fortags_allusers returns the correct bookmark basded on the searched tag" do
  
    order_by = "most_recent"
    tag_array = ["sample_tag"]

    array = Array.new
    array = Bookmark.search_fortags_allusers(tag_array, order_by)

    # each element of result_array is a hash with elements    
    assert (Bookmark.find_by_id(1).bmappings[0].title.eql?(array[0]["title"]))
   end

   test "search_fortags_foruser returns correct bookmark for that user based on searched tags" do
  
    order_by = "most_recent"
    tag_array = ["sample_tag"]
    user_id = @user2.id

    array = Array.new
    array = Bookmark.search_fortags_foruser(tag_array, user_id, order_by)

    # each element of result_array is a hash with elements    
    assert (Bookmark.find_by_id(1).bmappings[0].title.eql?(array[0]["title"]))
   end

  test "search_fortags_allusers returns correct bookmark based on searched tags" do
  
    order_by = "most_recent"
    tag_array = ["sample_tag"]

    array = Array.new
    array = Bookmark.search_fortags_allusers(tag_array, order_by)

    # each element of result_array is a hash with elements    
    assert (Bookmark.find_by_id(1).bmappings[0].title.eql?(array[0]["title"]))
   end   

  test 'add_bmapping correctly add' do
    
    bookmark_id = @existing_bookmark.id
    b_title = "Test title"
    session_user_id = @user2.id
    b_description = "Test description"
    b_tags_text = "tags tags tags"
    bmapping_id = Bmapping.add_bmapping(bookmark_id, b_title, session_user_id, b_description, b_tags_text)  

    assert (Bmapping.find_by_id(bmapping_id).title.eql?(b_title))

  end

  test 'because both topic and bmapping exist add_bmapping_signuptopic does not add a new topic' do
    
    #assert (SignUpTopic.count == 1) 

    topic_id = 1
    bmapping_id = 1
    bmapping_id = Bmapping.add_bmapping_signuptopic(topic_id, bmapping_id)  


    assert (!(SignUpTopic.count > 2))

  end

end