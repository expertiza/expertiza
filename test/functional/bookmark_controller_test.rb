require 'test_helper'
require 'bookmarks_controller'


class BookmarksControllerTest < ActionController::TestCase

fixtures :users, :roles, :participants,:bmappings, :bmappings_tags, :bmapping_ratings, :bookmark_rating_rubrics,:bookmarks, :sign_up_topics
  fixtures :users
  fixtures :assignments
  fixtures :questionnaires
  fixtures :courses
  set_fixture_class :system_settings => 'SystemSettings'
  fixtures :system_settings
  fixtures :content_pages
  @settings = SystemSettings.find(:first)

 def setup
    @controller = BookmarksController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    #@request.host = 'test.host.com'

    @request.session[:user] = User.find(users(:admin).id )
    roleid = User.find(users(:admin).id).role_id
    Role.rebuild_cache

    Role.find(roleid).cache[:credentials]
    @request.session[:credentials] = Role.find(roleid).cache[:credentials]
    # Work around a bug that causes session[:credentials] to become a YAML Object
    @request.session[:credentials] = nil if @request.session[:credentials].is_a? YAML::Object
    @settings = SystemSettings.find(:first)
    AuthController.set_current_role(roleid,@request.session)
    #   @request.session[:user] = User.find_by_name("suadmin")
  end


def test_view_bookmarks 

get :view_bookmarks
assert_response 302

end


def test_view_bookmarks_most_recent 

get :view_bookmarks, :order_by => "most recent"
assert_response 302

end


def test_view_bookmarks_most_popular
get :view_bookmarks, :order_by => "most popular"
assert_response 302
end


def test_manage_bookmarks
get :manage_bookmarks, :user => users(:student1)
assert_response 302 
end


def test_search_bookmarks

end


def test_add_bookmark_with_id 
	get(:add_bookmark, {:b_url => "www.google.com",
		                         :b_title          => "google",
		                         :b_tags_text      => "google it",
		                         :b_description    => "its google",                               
		                         :user => users(:admin), 
					:topicid => 243819443 },session_for(users(:admin)))
			
	assert_redirected_to  :action => 'view_topic_bookmarks', :id => :topicid

end



def test_add_bookmark_without_id

get :add_bookmark, :b_url => "www.google.com",
                                 :b_title          => "google",
                                 :b_tags_text      => "google it",
                                 :b_description    => "its google",                               
                                 :user => "student1", 
				:topicid => 'nil'
				

			
assert_redirected_to  :action => 'manage_bookmarks'
end


def test_copy_bookmark
get :add_bookmark, :b_url => "www.wikipedia.com",
                                 :b_title          => "wikipedia",
                                 :b_tags_text      => "wiki it",
                                 :b_description    => "it's wiki",                               
                                 :user => users(:student2), 
				:topicid => 'nil'
				

			
assert_redirected_to  :action => 'manage_bookmarks'
end


def test_edit_bookmark

get :add_bookmark, :b_url => "www.google.com",
                                 :b_title          => "google",
                                 :b_tags_text      => "google it",
                                 :b_description    => "it's google",                               
                                 :user => users(:student3), 
				:topicid => 'nil'
				

			
assert_redirected_to  :action => 'manage_bookmarks'
end

def test_view_review_bookmarks
get :view_review_bookmarks, :id =>participants(:par1).id

assert_response 302

end

def test_view
get :view, {:id => bmappings(:bmapping1).id}
assert_response 302
end

def test_create_rating_rubric_not_empty
post :create_rating_rubric, :params => {:display_text => "Did you like the bookmark?", :minimum_rating => 1, :maximum_rating => 1 }

assert_template :view_rating_rubric_form

end

def test_create_rating_rubric_empty
post :create_rating_rubric, :display_text => "", :minimum_rating => "", :maximum_rating => "" 

assert_redirected_to :action => :view_rating_rubrics
end



end
