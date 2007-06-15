class ReviewController < ApplicationController
  def list
    # lists the reviews that the current user is assigned to do
    user_id = session[:user].id
    assignment_id = params[:assignment_id]
    @review_mappings = ReviewMappings.find_by_sql("select * from review_mappings, reviews where reviewer_id = " +
                                user_id + "and assignment_id =" + assignment_id + "and reviews.review_mapping_id = review_mappings.id")
    @review_pages, @reviews = paginate :users, :order => 'review_num_for_reviewer', :conditions => ["parent_id = ? AND role_id = ?", user_id, Role::ADMINISTRATOR], :per_page => 50
  end
  
  def display
    # Display the review(s) of the student whom this author has selected to review now.
    # The reviews of old versions should open in a different window, so that the reviewer can scroll through
    # them, and through the author's reponses (if any).
    # If a review has already been submitted for the current version, then the prose comments should
    # populate the text boxes that the reviewer is about to revise.
    # In any case, if this reviewer has reviewed this author on (any version of) this assignment, the 
    # previously assigned scores should populate the dropboxes used to assign scores.
    # If a rubric question has been added since the last time this reviewer reviewed this author, a
    # default score (probably the lowest possible score) should appear in the dropbox.
  end
  
  def view_review
    @questions = Question.find(:all,:conditions => ["rubric_id = ?",(Assignment.find((ReviewMapping.find(params[:id])).assignment_id)).review_rubric_id])
    @review = Review.find_by_review_mapping_id(params[:id])
    @rubric = Rubric.find((Assignment.find((ReviewMapping.find(params[:id])).assignment_id)).review_rubric_id)
    @valuemap = Hash.new
    for i in @rubric.min_question_score..@rubric.max_question_score
      @valuemap[i] = i
    end
    if(@review)
     @found = true
     
    else
      
    end
  end
  
  def edit_review
    
  end
  
  def new_review
    
  end
  
  def feedback
    @reviewer_id = session[:user].id
    @assignment_id = params[:id]
    @review_mapping = ReviewMapping.find(:all,:conditions => ["reviewer_id = ? and assignment_id = ?", @reviewer_id, @assignment_id])   
  end
  
end
