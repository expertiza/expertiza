require File.dirname(__FILE__) + '/../test_helper'
require 'review_controller'

# Re-raise errors caught by the controller.
class ReviewController; def rescue_action(e) raise e end; end

class ReviewControllerTest < Test::Unit::TestCase
  fixtures :review_mappings
  fixtures :reviews
  fixtures :review_scores

  def setup
    @controller = ReviewController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    @reviewMapping = review_mappings(:first)
    @review = reviews(:review1)
  end
  
  # 1301 Add a new review
  def test_create_review
    post :create_review, :mapping_id => @reviewMapping.id, :new_review => { :comments => "test" }
    assert_response :redirect 
    assert_equal 'Review was successfully saved.',flash[:notice]   
  end
  
  # 1302 Edit a review
  def test_update_review
   post :update_review, :review_id => @review.id , :new_review => { :comments => "new test" },
         :new_review_score => { "0", {:comments => "first"}, 
                                "1", {:comments => "second"} },
         :new_question => {"0"=>"0", "1"=>"1"},
         :new_score => {"0", "1"}
   assert_response :redirect
   assert_equal flash[:notice], 'Review was successfully saved.'
  end
end
