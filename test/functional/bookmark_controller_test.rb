require File.dirname(__FILE__) + '/../test_helper'
require 'review_controller'


class BookmarkControllerTest < Test::Unit::TestCase



def test_view_bookmarks

get :view_bookmarks 
assert_response :success

end


def test_view_bookmarks_most_recent

get :view_bookmarks :order_by => "most recent"
assert_response :success

end


def test_view_bookmarks_most_popular

get :view_bookmarks :order_by => "most popular"
assert_response :success

end


def test_manage_bookmarks

get :manage_bookmarks, :user => Users(:student1)
assert_response :success 

end


def test_search_bookmarks



end

def test_create_bookmark
bookmark = Bookmark.new{:b_url => "www.google.com",
                                 :b_title          => "google",
                                 :b_tags_text      => "google it",
                                 :b_description    => "it's google",                               
                                 :user => Users(:student1), }
assert bookmark.save

end

def test_add_bookmark_with_id

get :add_bookmark, :b_url => "www.google.com",
                                 :b_title          => "google",
                                 :b_tags_text      => "google it",
                                 :b_description    => "it's google",                               
                                 :user => Users(:student1), 
				:topicid => Switch_topics(:two).topic_id
				

			
assert_redirected_to  :action => 'view_topic_bookmarks', :id => :topicid

end



def test_add_bookmark_without_id

get :add_bookmark, :b_url => "www.google.com",
                                 :b_title          => "google",
                                 :b_tags_text      => "google it",
                                 :b_description    => "it's google",                               
                                 :user => Users(:student1), 
				:topicid => 'nil'
				

			
assert_redirected_to  :action => 'manage_bookmarks'
end


def test_copy_bookmark
get :add_bookmark, :b_url => "www.wikipedia.com",
                                 :b_title          => "wikipedia",
                                 :b_tags_text      => "wiki it",
                                 :b_description    => "it's wiki",                               
                                 :user => Users(:student2), 
				:topicid => 'nil'
				

			
assert_redirected_to  :action => 'manage_bookmarks'
end


def test_edit_bookmark

get :add_bookmark, :b_url => "www.google.com",
                                 :b_title          => "google",
                                 :b_tags_text      => "google it",
                                 :b_description    => "it's google",                               
                                 :user => Users(:student3), 
				:topicid => 'nil'
				

			
assert_redirected_to  :action => 'manage_bookmarks'
end



end
