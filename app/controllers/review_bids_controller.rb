class ReviewBidsController < ApplicationController
  require "net/http"
  #require "uri"
  require "json"

  def action_allowed?
    ['Student'].include? current_role_name
  end

  def review_bid
    render 'sign_up_sheet/review_bid'
  end
end
