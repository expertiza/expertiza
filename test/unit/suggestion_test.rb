require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase

  def test_add_comment

    suggestioncomment = SuggestionComment.new
    suggestioncomment.commenter = "vsingh3"#session[:user].name
    suggestioncomment.comments  = "comment"
    suggestioncomment.vote  = "yes"
    suggestioncomment.suggestion_id = 1    

    if suggestioncomment.save
      suggestion=Suggestion.find(suggestioncomment.suggestion_id)
      assert_not_nil(suggestion, "suggestion is nil")
    end    
  end
  
  def test_add_comment_without_comment_field

    params = {}
    suggestioncomment = SuggestionComment.new(params)
    suggestioncomment.suggestion_id = params[:id]
    suggestioncomment.commenter = "vsingh3"#session[:user].name
    suggestioncomment.vote  = "yes"
    suggestioncomment.suggestion_id = 1    

    assert !suggestioncomment.save
  end
  
  def test_add_suggestion
    params = {:title => "title1",:description => "description1", :signup_preference => "kuch bhi"}
    suggestion = Suggestion.new(params)
    suggestion.assignment_id = 2
    suggestion.status = 'Initiated'
    suggestion.unityID = 'capsang'
    #suggestion.control=1
    
    assert suggestion.save    
  end
  
  def test_add_suggestion_no_title
    params = {:description => "description1", :signup_preference => "kuch bhi"}
    suggestion = Suggestion.new(params)
    suggestion.assignment_id = 2
    suggestion.status = 'Initiated'
    suggestion.unityID = 'capsang'
    #suggestion.control=1
    
    assert !suggestion.save    
  end
  
  def test_add_suggestion_no_description
    params = {:title => "title1", :signup_preference => "kuch bhi"}
    suggestion = Suggestion.new(params)
    suggestion.assignment_id = 2
    suggestion.status = 'Initiated'
    suggestion.unityID = 'capsang'
    #suggestion.control=1
    
    assert !suggestion.save    
  end
  
end
