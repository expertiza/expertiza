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
    @review = Review.find(params[:id])
    @review_scores = @review.review_scores
    @mapping = ReviewMapping.find(@review.review_mapping_id)
    @assgt = Assignment.find(@mapping.assignment_id)    
  end
  
  def edit_review
    
  end
  
  def new_review
    @review = Review.new
    @mapping = ReviewMapping.find(params[:id])
    @assgt = Assignment.find(@mapping.assignment_id)
    @questions = Question.find(:all,:conditions => ["rubric_id = ?", @assgt.review_rubric_id]) 
    @rubric = Rubric.find(@assgt.review_rubric_id)
    @max = @rubric.max_question_score
    @min = @rubric.min_question_score    
  end
  
  def create_review
     params.each do |elem|
       puts "#{elem[0]}, #{elem[1]}" 
     end
     @review = Review.new
     @review.review_mapping_id = params[:mapping_id]
     
     if params[:new_review_score]
      # The new_question array contains all the new questions
      # that should be saved to the database
      for review_key in params[:new_review_score].keys
        rs = ReviewScore.new(params[:new_review_score][review_key])
        rs.question_id = params[:new_question][review_key]
        rs.score = params[:new_score][review_key]
        @review.review_scores << rs
      end      
    end
    if @review.save
      flash[:notice] = 'Rubric was successfully saved.'
      redirect_to :action => 'list_reviews', :id => params[:assgt_id]
    else # If something goes wrong, stay at same page
      render :action => 'view_review'
    end
  end
  
 
  
  def feedback
    @reviewer_id = session[:user].id
    @assignment_id = params[:id]
    @questions = Question.find(:all,:conditions => ["rubric_id = ?", Assignment.find(@assignment_id).review_rubric_id])
    @review_mapping = ReviewMapping.find(:all,:conditions => ["reviewer_id = ? and assignment_id = ?", @reviewer_id, @assignment_id])   
  end
  
  def list_reviews
    @reviewer_id = session[:user].id
    @assignment_id = params[:id]
    @questions = Question.find(:all,:conditions => ["rubric_id = ?", Assignment.find(@assignment_id).review_rubric_id])
    @review_mapping = ReviewMapping.find(:all,:conditions => ["reviewer_id = ? and assignment_id = ?", @reviewer_id, @assignment_id])     
  end
  
end
