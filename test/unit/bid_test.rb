require 'test_helper'

class BidTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def setup
    @bid = Bid.new
  end

  test "save bid with valid data" do
  end

  test "save bid with invalid data" do
  end

  test "delete bid" do
    @bid.delete
    assert @bid.nil?
  end
end
