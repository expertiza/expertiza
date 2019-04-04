class ReviewBidsController < ApplicationController
  before_action :set_review_bid, only: [:show, :edit, :update, :destroy]

  # GET /review_bids
  def index
    @review_bids = ReviewBid.all
  end

  # GET /review_bids/1
  def show
  end

  # GET /review_bids/new
  def new
    @review_bid = ReviewBid.new
  end

  # GET /review_bids/1/edit
  def edit
  end

  # POST /review_bids
  def create
    @review_bid = ReviewBid.new(review_bid_params)

    if @review_bid.save
      redirect_to @review_bid, notice: 'Review bid was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /review_bids/1
  def update
    if @review_bid.update(review_bid_params)
      redirect_to @review_bid, notice: 'Review bid was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /review_bids/1
  def destroy
    @review_bid.destroy
    redirect_to review_bids_url, notice: 'Review bid was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_review_bid
      @review_bid = ReviewBid.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def review_bid_params
      params.require(:review_bid).permit(:topic_id, :student_id, :priority)
    end
end
