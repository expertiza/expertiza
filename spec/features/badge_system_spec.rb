# require '../rails_helper.rb'
# Method is created to autofill all the fields required to create an assignment

describe 'badge system' do
  ###
  # Please do not share this file with other teams.
  # Please follow the TDD process as much as you can.
  # Use factories to create necessary DB records.
  # Please avoid duplicated code as much as you can by moving the code to before(:each) block or separated methods.
  # RSpec feature tests examples: spec/features/airbrake_expection_errors_feature_tests_spec.rb
  # For single user login, please use login_as method.
  # If your tests need to switch to different users frequently,
  # please use stub_current_user(user, user.role.name, user.role) each time to stub login behavior.
  ###
  
  before(:each) do
  	create(:instructor)
  	login_as("instructor6")
  	create(:deadline_type, name: "submission")
    create(:deadline_type, name: "review")
    create(:deadline_type, name: "metareview")
    create(:deadline_type, name: "drop_topic")
    create(:deadline_type, name: "signup")
    create(:deadline_type, name: "team_formation")
    create(:deadline_right)
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')
    (1..3).each do |i|
      create(:course, name: "Course #{i}")
    end
  	create(:assignment, name: 'testAssignment')
  	create(:topic)
  	create(:assignment_due_date)
  	create_list(:participant, 3)
  	create(:assignment_node)
  	create(:badge, name: "GoodReviewer", description: "You are a good reviewer")
  	create(:badge, name: "GoodTeammate", description: "You are a good teammate")
  	create(:review_grade)
  	create(:signed_up_team)
  	create(:assignment_team)
  	create(:team_user)
  	create(:course_team)
  	create(:response)
  	create(:review_response_map)
  	create(:meta_review_response_map)
  
 	 	@assignment_id = Assignment.where(name: "testAssignment").first.id
  
  	@good_reviewer_badge = Badge.where(name: "GoodReviewer").first.id
  	@good_teammate_badge = Badge.where(name: "GoodTeammate").first.id
  	
  	@participant_id = Participant.first.id
  	
  	create(:assignment_badge, badge_id: @good_reviewer_badge, assignment_id: @assignment_id)
  	create(:assignment_badge, badge_id: @good_teammate_badge, assignment_id: @assignment_id)
  	
  	create(:awarded_badge, badge_id: @good_reviewer_badge, participant_id: @participant_id)
  	create(:awarded_badge, badge_id: @good_teammate_badge, participant_id: @participant_id)
  end
  context 'in assignments#edit page' do
    it 'has a tab named \'Badges\'' do
    	
    	user = User.find_by(name: "instructor6")
    	
    	stub_current_user(user, user.role.name, user.role)
			visit "/assignments/#{@assignment_id}/edit"
			click_link 'Badges'
			
			# context 'when switching to \'Badges\' tab' do
			#   it 'allows instructor to change the thresholds of two badges (by default is 95) and save thresholds to DB' do
			  
			#   end
			# end
		end
  end

  context 'when a student receives a very high average teammate review grade (higher than 95 by default)' do
    it 'assigns the \'Good teammate\' badge to this student on student_task#list page' do
    	
    	@user_name = User.find(Participant.find(@participant_id).user_id).name
    	
    	user = User.find_by(name: @user_name)
    	stub_current_user(user, user.role.name, user.role)
    	
    	participant = Participant.find(@participant_id);
    	
    	teammate_grade = AwardedBadge.get_teammate_review_score(participant)
    	threshold = AssignmentBadge.where(badge_id: @good_teammate_badge, assignment_id: @assignment_id).first.threshold
    	
    	puts "-------"
    	puts teammate_grade
    	puts "-------"
    	
    	if teammate_grade
		  	if teammate_grade > threshold
		  		visit "/student_task/list"
		  		puts page.body
		  		expect(page).to have_xpath("//img[@src='/assets/badges/goodTeammate.png']")
		  	end
		  end
    end
  end

  context 'when a student receives a very high review grades assigned by teaching staff (higher than 95 by default)' do
    it 'assigns the \'Good reviewer\' badge to this student on student_task#list page' do
    @user_name = User.find(Participant.find(@participant_id).user_id).name
    	
    	user = User.find_by(name: @user_name)
    	stub_current_user(user, user.role.name, user.role)
    	
    	review_grade = ReviewGrade.where(participant_id: @participant_id).first.grade_for_reviewer
    	threshold = AssignmentBadge.where(badge_id: @good_reviewer_badge, assignment_id: @assignment_id).first.threshold
    	
    	if review_grade > threshold
    		visit "/student_task/list"
    		puts page.body
    		expect(page).to have_xpath("//img[@src='/assets/badges/goodReviewer.png']")
    	end
    end
  end

  context 'on participants#list page' do
    it 'allows instructor to view badges assignment statuses of all participants' do
    	user = User.find_by(name: "instructor6")
    	
    	stub_current_user(user, user.role.name, user.role)
    	
    	visit "/participants/list?id=#{@assignment_id}&model=Assignment"
    	
    	page.should have_content("Badge")
    end
  end
end
