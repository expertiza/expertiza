And /^I have a work review with score of "([^"]*)"$/ do |score|
    within(:xpath, "//tr[@id='user_reviews']//td//table[@class='.grades']")  do
        should have_content(score)
    end
end

Then /^I should see the three reviews for my submitted work with corresponding scores$/ do
   flag =find('#user_reviews').visible?
   flag.should eql(true)
end

And /^I have a feedback review with score of "([^"]*)"$/ do |score|
      within(:xpath, "//tr[@id='user_feedback']//td//table[@class='.grades']")  do
        should have_content(score)
      end
end

Then /^I should see the author feedback review with corresponding score$/ do
  flag = find('#user_feedback').visible?
  flag.should eql(true)
end

And /^I have a teammate review with score of "([^"]*)"$/ do |score|
    within(:xpath, "//tr[@id='user_teammate_reviews']//td//table[@class='.grades']")  do
        should have_content(score)
    end
end

Then /^I should see the two teammate reviews with corresponding scores$/ do
  flag = find('#user_teammate_reviews').visible?
  flag.should eql(true)
end