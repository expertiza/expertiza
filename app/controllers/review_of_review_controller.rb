class ReviewOfReviewController < ApplicationController
    
   
  
  
    def get_student_directory(directory_path, directory_num)
        # This assumed that the directory num has already been set
        return RAILS_ROOT + "/pg_data/" + directory_path + "/" + directory_num
    end
  
    def find_review_phase(due_dates)
        # Find the next due date (after the current date/time), and then find the type of deadline it is.
        @very_last_due_date = DueDate.find(:all,:order => "due_at DESC", :limit =>1)
        next_due_date = @very_last_due_date[0]
        for due_date in due_dates
            if due_date.due_at > Time.now
                if due_date.due_at < next_due_date.due_at
                    next_due_date = due_date
                end
            end
        end
        @review_phase = next_due_date.deadline_type_id;
        return @review_phase
    end   
  
    def list_reviews
        @reviewer_id = session[:user].id
        @assignment_id = params[:id]
        @questions = Question.find(:all,:conditions => ["rubric_id = ?", Assignment.find(@assignment_id).review_rubric_id])
        @review_mapping = ReviewMapping.find(:all,:conditions => ["reviewer_id = ? and assignment_id = ?", @reviewer_id, @assignment_id])     
    end
  
    def new_review_of_review
        @review_of_review_mapping = ReviewOfReviewMapping.find(params[:id])
        @review = Review.find(@review_of_review_mapping.review_id)
        @review_scores = @review.review_scores
        @mapping = ReviewMapping.find(@review.review_mapping_id)
        @assgt = Assignment.find(@mapping.assignment_id)
      
        @review_of_review = ReviewOfReview.new
        @questions = Question.find(:all,:conditions => ["rubric_id = ?", @assgt.review_of_review_rubric_id]) 
        @rubric = Rubric.find(@assgt.review_of_review_rubric_id)
        @max = @rubric.max_question_score
        @min = @rubric.min_question_score
    end
    
    def view_review_of_review
        
    end
    def list_review_of_review
        
    end
    
    def create_review_of_review
        @review_of_review = ReviewOfReview.new
        @review_of_review.review_of_review_mapping_id = params[:mapping_id]
        @mapping = ReviewOfReviewMapping.find(params[:mapping_id])
        @assignment = Assignment.find(@mapping.assignment_id)
        @due_dates = DueDate.find(:all, :conditions => ["assignment_id = ?",@assignment_id])
        @review_phase = find_review_phase(@due_dates)
        #if(@review_phase != 2)


        if params[:new_review_score]
            # The new_question array contains all the new questions
            # that should be saved to the database
            for review_key in params[:new_review_score].keys
                rs = ReviewOfReviewScore.new(params[:new_review_score][review_key])
                rs.question_id = params[:new_question][review_key]
                rs.score = params[:new_score][review_key]
                @review_of_review.review_of_review_scores << rs
            end      
        end
        if @review_of_review.save
            flash[:notice] = 'Rubric was successfully saved.'
            redirect_to :controller => 'review', :action => 'list_reviews', :id => params[:assgt_id]
        else # If something goes wrong, stay at same page
            render :action => 'view_review'
        end
    end
    
  
end
