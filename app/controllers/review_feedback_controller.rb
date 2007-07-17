class ReviewFeedbackController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @review_feedback_pages, @review_feedbacks = paginate :review_feedbacks, :per_page => 10
  end

  def show
    @review_feedback = ReviewFeedback.find(params[:id])
  end

  def new
    @review_feedback = ReviewFeedback.new
  end

  def create
    @review_feedback = ReviewFeedback.new(params[:review_feedback])
    if @review_feedback.save
      flash[:notice] = 'ReviewFeedback was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @review_feedback = ReviewFeedback.find(params[:id])
  end

  def update
    @review_feedback = ReviewFeedback.find(params[:id])
    if @review_feedback.update_attributes(params[:review_feedback])
      flash[:notice] = 'ReviewFeedback was successfully updated.'
      redirect_to :action => 'show', :id => @review_feedback
    else
      render :action => 'edit'
    end
  end

  def destroy
    ReviewFeedback.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
