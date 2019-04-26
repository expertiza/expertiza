require 'database_cleaner'
require 'byebug'

describe 'Integration tests for viewing grades: ', js: true do
# describe 'Integration tests for viewing grades: ' do
  before(:context) do
    DatabaseCleaner.strategy = :truncation, {:pre_count => true, :reset_ids => true}
    DatabaseCleaner.start
  end

  after(:context) do
    DatabaseCleaner.clean

    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.start
  end

  context 'when checking grade bar chart' do
    #setup roles
    let!(:role1) {create(:role_of_student)}
    let!(:role2) {create :role_of_instructor}
    let!(:role3) {create :role_of_administrator}
    let!(:role4) {create :role_of_superadministrator}

    #add users
    let!(:user1) {create :instructor}
    let!(:user2) {4.times do |i|
      create :student, name: "user#{i + 1}"
    end
    }

    #add assignments
    let!(:assignment1) {create :assignment, name: "final123"}
    let!(:deadline_right1) {
      rights = %w(NO LATE OK)
      rights.each {|right| create :deadline_right, name: right}
    }
    let!(:assignment_due_date1) {create :assignment_due_date}
    let!(:assignment_team1) {2.times {create :assignment_team}}

    # add users to teams
    let!(:team_user1) {
      user_id = 2
      2.times do |team_id|
        2.times do
          create(:team_user, team: Team.find(team_id + 1), user: User.find(user_id))
          user_id += 1
        end
      end}

    let!(:participant1) {
      user_id = 2
      4.times do
        create :participant, user_id: user_id
        user_id += 1
      end}


    let!(:review_response_map1) {
      participant_id = 4
      2.times do |team_id|
        2.times do
          create(:review_response_map, reviewee: AssignmentTeam.find(team_id + 1), reviewer: AssignmentParticipant.find(participant_id))
          participant_id -= 1
        end
      end}

    #questionnaires/reviews
    let!(:q_aire) {
      2.times {|i| create(:questionnaire, name: "Test questionnarie#{i + 1}")}
    }

    let!(:assignment1_q_aire) {
      2.times {|round| create(:assignment_questionnaire, used_in_round: round + 1)}
    }

    let!(:questions) {5.times {create :question}}

    #qustionnaire/teammate
    let!(:t_aire) {create(:questionnaire, name: "Temmate questionnarie", display_type: "TeammateReview", type: "TeammateReviewQuestionnaire")}
    let!(:assignment1_tq_aire) {create(:assignment_questionnaire, questionnaire: t_aire)}
    let!(:teammate_questions) {5.times {create :question, questionnaire: t_aire}}



    let!(:q_advice) {create :question_advice}


    let!(:data_reponse) {
      2.times do |round|
        4.times do |map_id|
          5.times do
            create(:response, is_submitted: true, response_map: ReviewResponseMap.find(map_id + 1), round: round + 1)
          end
        end
      end}

    #answers
    let!(:answers1) {
      response_id = 1
      2.times do #round
        5.times do |i|
          4.times do |ii|
            create(:answers, question: Question.find(i + 1), answer: 1 + ii, response: Response.find(response_id))
            response_id += 1
          end
        end
      end}

    #ScoreView
    let!(:score_view1) {
      index = 1
      2.times do |round|
        5.times do |question_id|
          4.times do
            create(:score_view,
                   question_weight: 1,
                   type: "Criterion",
                   q1_id: 1,
                   q1_name: "q_aire.first.name",
                   q1_instructor_id: 2,
                   q1_private: 0,
                   q1_min_question_score: 0,
                   q1_max_question_score: 5,
                   q1_type: "ReviewResponseMap",
                   q1_display_type: "Review",
                   ques_id: question_id + 1,
                   ques_questionnaire_id: 1,
                   s_id: index,
                   s_question_id: question_id + 1,
                   s_score: Answer.find(index).answer,
                   s_comments: nil,
                   s_response_id: index
            )
            index += 1
          end
        end
      end}

    # it 'is visible' do
      it 'is visible', :driver => :selenium_chrome do
        Capybara.page.driver.browser.manage.window.maximize
        Capybara.default_max_wait_time = 600

      # byebug

      login_as("instructor6")
      visit view_grades_path(:id => assignment1.id)

      # byebug

      expect(page).to have_selector('#chart_div', visible: true)
    end

  end
end
