require 'test_helper'

class BidTest < ActiveSupport::TestCase
  fixtures :bids

  def setup
    @bid = bids(:bid1)
  end

  def test_get_bid
    assert_kind_of Bid, @bid
    assert_equal bids(:bid1).team_id, @bid.team_id
    assert_equal bids(:bid1).topic_id, @bid.topic_id
  end

  def test_update_bid
    @bid.team_id = "2"
    @bid.save
    @bid.reload
    assert_equal 2, @bid.team_id
  end

  def test_destroy
    @bid.destroy
    assert_raise(ActiveRecord::RecordNotFound){ Course.find(@bid.id) }
  end

  def test_create_bid
    bid = Bid.new
    bid.topic_id= "1"
    bid.team_id = "2"
    bid.save! # an exception is thrown if the user is invalid
  end
end
