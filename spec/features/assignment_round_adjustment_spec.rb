def questionnaire_options(assignment, type, _round = 0)
  questionnaires = Questionnaire.where(['private = 0 or instructor_id = ?', assignment.instructor_id]).order('name')
  options = []
  questionnaires.select {|x| x.type == type }.each do |questionnaire|
    options << [questionnaire.name, questionnaire.id]
  end
  options
end

def get_questionnaire(finder_var = nil)
  if finder_var.nil?
    AssignmentQuestionnaire.find_by(assignment_id: @assignment.id)
  else
    AssignmentQuestionnaire.where(assignment_id: @assignment.id).where(questionnaire_id: get_selected_id(finder_var))
  end
end

def get_selected_id(finder_var)
  if finder_var == "ReviewQuestionnaire_test"
    ReviewQuestionnaire.find_by(name: finder_var).id
  elsif finder_var == "AuthorFeedbackQuestionnaire_test"
    AuthorFeedbackQuestionnaire.find_by(name: finder_var).id
  elsif finder_var == "TeammateReviewQuestionnaire_test"
    TeammateReviewQuestionnaire.find_by(name: finder_var).id
  end
end





describe "assignment function" do
  before(:each) do
    create(:deadline_type, name: "submission")
    create(:deadline_type, name: "review")
    create(:deadline_type, name: "metareview")
    create(:deadline_type, name: "drop_topic")
    create(:deadline_type, name: "signup")
    create(:deadline_type, name: "team_formation")
    create(:deadline_right)
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')
  end

  describe "creation page", js: true do
    before(:each) do
      
        create(:course, name: "Course_test")
	login_as("instructor6")
      visit "/assignments/new?private=0"

      fill_in 'assignment_form_assignment_name', with: 'multiround_Assignment'
      select('Course_test', from: 'assignment_form_assignment_course_id')
      fill_in 'assignment_form_assignment_directory_path', with: 'testDirectory'
      fill_in 'assignment_form_assignment_spec_location', with: 'testLocation'
      check("assignment_form_assignment_microtask")
      check("assignment_form_assignment_reviews_visible_to_all")
      check("assignment_form_assignment_is_calibrated")
      uncheck("assignment_form_assignment_availability_flag")
      expect(page).to have_select("assignment_form[assignment][reputation_algorithm]", options: ['--', 'Hamer', 'Lauw'])
	click_link 'Due date'
	fill_in 'assignment_form_assignment_rounds_of_reviews', with: '5'
    click_button 'set_rounds'
	#edit 	1
	click_button 'Create'
     assignment = Assignment.where(name: 'multiround_Assignment').first
     p assignment
    #login_as("instructor6") 
   #visit "/assignments/#{assignment.id}/edit"
   #sleep 5
 	#find_link('Topics').click


     
     
     
#started editing here god save me
 end 
 it "verfies number of review rounds" do
 	 

 	assignment_test = Assignment.where(name: 'multiround_Assignment').first
 	p assignment_test.rounds_of_reviews
 	expect(assignment_test).to have_attributes(rounds_of_reviews: 5)
    visit "/assignments/#{assignment_test.id}/edit"
    find_link('Topics').click
end
end
end
