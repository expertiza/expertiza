require 'test_helper'

class LogEntryTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
  test "create user login" do
    user = User.new
    user.name="moon light"
    user.email="moonlight@hereko"
    assert(log.nil?)
  end
end
