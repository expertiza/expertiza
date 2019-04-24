require 'byebug'

include GradeInterfaceHelperSpec

describe 'Integration tests for viewing grades: ' do
  context 'when checking grade bar chart' do
    #setup roles
    let!(:role1) {create(:role_of_student)}
    let!(:role2) {create :role_of_instructor}
    let!(:role3) {create :role_of_administrator}
    let!(:role4) {create :role_of_superadministrator}

    #add users
    let!(:user1) {create :instructor}
    let!(:user2) {2.times {create :student}}

    #add assignments
    let!(:assignment1) {create :assignment, name: "final123"}
    let!(:assignment_team1) {create :assignment_team}
    let!(:team_user1) {create :team_user}
    let!(:participant1) {create :participant}
    let!(:review_response_map1) {create :review_response_map}

    let!(:q_aire) {create :questionnaire}
    let!(:assignment1_q_aire) {create :assignment_questionnaire}

    let!(:questions) {5.times {create :question}}
    let!(:q_advice) {create :question_advice}

    let!(:data_reponse) {create :response, is_submitted: true}

    let!(:answers1) {5.times do |i|
      5.times do |ii|
        create(:answers, question_id: i + 1, answer: 90 + ii)
      end
    end}


    it 'is visible' do
      login_as("instructor6")
      visit view_grades_url(:id => assignment1.id)
      expect(page).to have_selector('#chart_div', visible: true)
    end

  end
end
