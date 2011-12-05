And /^I create a review questionnaire called "(\S+)"$/ do |questionnaire|
=begin
  find(:xpath, "//a/img[@title='Create Public Review']/..").click
  fill_in 'questionnaire_name', :with => questionnaire
  page.evaluate_script("$('question_1_txt').text(\"question one\")")
  click_button 'Create review'
=end

  admin = User.find_by_name("admin")
  puts "admin id = #{admin.id}"
  Questionnaire.create!({
      :name => 'test_review_questionnaire',
      :min_question_score => 2,
      :max_question_score => 5,
      :type => 'ReviewQuestionnaire',
      :display_type => 'Review',
      :instructor_id => admin.id
                       })
  questionnaires = Questionnaire.find_by_name('test_review_questionnaire')
  questionnaires.save!
  puts questionnaires
  puts "id = #{questionnaires.id}"
  Question.create!({
      :questionnaire_id => questionnaires.id,
      :txt => 'question one',
      :weight => 1
                  })

end

Then /^I should see "(\S+)" under list of questionnaires$/ do |questionnaire|
#  find(:xpath, "//a[contains(.,'Review rubrics')]").click
  should have_content questionnaire
end