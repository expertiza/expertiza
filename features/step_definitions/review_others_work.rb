Given 'I am assigned as a reviewer for an assignment' do
  step 'a review named "test_review" exists'
  step 'an assignment named "test_assignment" exists'
  step 'I am participating in "test_assignment"'
end

Given /^a review named "(\S+)" exists$/ do |review|

  Questionnaire.create({
    :name => 'test_review',
    :type => 'ReviewQuestionnaire',
    :display_type => 'Review',
    :max_question_score => 10
  })

  Question.create({
    :questionnaire_id => Questionnaire.find_by_name('test_review'),
    :txt => 'Originality',
    :weight => 5
  })

end

Given 'I am participating in "test_assignment"' do
  step 'a student with the username "student1" exists'
  step 'a student with the username "student2" exists'
  step '"student2" is assigned as the reviewer'
  click_button 'Logout'
end

Given /^"(\S+)" is assigned as the reviewer/ do |username|
  find(:xpath, "//a/img[@title='Assign reviewers']/..").click
  find(:xpath, "//a[contains(.,'add reviewer')]").click
  fill_in 'user_name',:with => username
  click_button 'Add Reviewer'
end

Given 'I open that particular assignment and begin review' do
  step 'I am logged in as "student2"'
  step 'I should find "test_assignment" under list of assignments'
  step 'I click the "test_assignment" link'

  find(:xpath, "//a[contains(.,'Others' work'')]").click
  find(:xpath, "//a[contains(.,'Begin')]").click
  fill_in 'responses_0_comments', :with => 'Yes'

  click_button 'Save Review'
end

Given 'I should see "Your response was successfully saved"' do
  if(find(:xpath, "//a[contains(.,'Your response was successfully saved')]").visible?)
    assert(true)
  else
    assert(false)
  end
end
