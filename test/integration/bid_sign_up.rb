require File.join(File.dirname(__FILE__), '..', 'test_helper.rb')

class BidSignUpTest < ActionDispatch::IntegrationTest
  fixtures :all

  # Given I am on the sign up topics page
  # When I press bid
  # Then I should see the notice that my bid has submitted
  # And I should see the topic in my teams bids
  # And I should see a delete icon for that topic
  # Replace this with your real tests.

  # Given I am on the sign up topics page
  # And my team has 3 bids
  # Then I should see the 3 topics my team has bid on

  # Given I am on the sign up topics page
  # And my team has 3 bids
  # When I press bid
  # Then I should should see a notice that says my team has reached max bids
  # And I should see no change in bid topics

end