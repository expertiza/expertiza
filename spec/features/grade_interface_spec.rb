
describe 'Integration tests for viewing grades: ', js: true do
  context 'when checking grade bar chart' do
    # setup roles
    let!(:role1) { create(:role_of_student) }
    let!(:role2) { create :role_of_instructor }
    let!(:role3) { create :role_of_administrator }
    let!(:role4) { create :role_of_superadministrator }

    # add users
    let!(:user1) { create :instructor }
    let!(:user2) do
      4.times do |i|
        create :student, name: "user#{i + 1}"
      end
    end

    let!(:deadline_right1) do
      rights = %w[NO LATE OK]
      rights.each {|right| create :deadline_right, name: right}
    end

    # add assignments 1
    let!(:assignment1) { create :assignment, name: "final123" }
    let!(:assignment_team1) { 2.times { create :assignment_team } }
    let!(:assignment_due_date1) { create :assignment_due_date }

    # add assignments 1
    let!(:assignment2) { create :assignment, name: "final456" }
    let!(:assignment_team2) { 2.times { create :assignment_team } }
    let!(:assignment_due_date2) { create(:assignment_due_date, assignment: assignment2) }

    # add users to teams
    let!(:team_user1) do
      user_id = 2
      2.times do |team_id|
        2.times do
          create(:team_user, team: Team.find(team_id + 1), user: User.find(user_id))
          user_id += 1
        end
      end
    end

    # add participants
    let!(:participant1) do
      2.times do |assignment_id|
        user_id = 2
        4.times do
          create :participant, user_id: user_id, assignment: Assignment.find(assignment_id + 1)
          user_id += 1
        end
      end
    end

    # add response_maps
    let!(:review_response_map1) do
      (1..2).each do |assignment_id|
        participant_id = 4
        (1..2).each do |team_id|
          2.times do
            create :review_response_map, reviewee: AssignmentTeam.find(team_id),
                                         reviewer: AssignmentParticipant.find(participant_id),
                                         assignment: Assignment.find(assignment_id)
            participant_id -= 1
          end
        end
      end
    end

    # questionnaires/reviews
    let!(:q_aire) do
      2.times {|i| create(:questionnaire, name: "Test questionnarie#{i + 1}") }
    end

    # assignment_questionnaires
    let!(:assignment1_q_aire) do
      (1..2).each do |assignment_id|
        (1..2).each {|round| create(:assignment_questionnaire, used_in_round: round, assignment: Assignment.find(assignment_id)) }
      end
    end

    let!(:questions) { 5.times { create :question } }

    # qustionnaire/teammate
    let!(:t_aire) { create(:questionnaire, name: "Temmate questionnarie", display_type: "TeammateReview", type: "TeammateReviewQuestionnaire") }
    let!(:assignment1_tq_aire) { create(:assignment_questionnaire, questionnaire: t_aire) }
    let!(:teammate_questions) { 5.times { create :question, questionnaire: t_aire } }

    # add question_advice
    let!(:q_advice) { create :question_advice }

    # add responses
    let!(:data_reponse) do
      2.times do # assignments
        response_review_index = 1
        (1..2).each do |round|
          4.times do # number of users seeded
            create :response, is_submitted: true, response_map: ReviewResponseMap.find(response_review_index), round: round
            response_review_index += 1
          end
        end
      end
    end

    # answers
    let!(:answers1) do
      2.times do # assignments
        response_id = 0
        2.times do # round
          (1..4).each do |seeded_user|
            response_id += 1
            (1..5).each do |question_number|
              create(:answers, question: Question.find(question_number), answer: seeded_user, response: Response.find(response_id))
            end
          end
        end
      end
    end

    # ScoreView
    let!(:score_view1) do
      index = 1
      2.times do # assignments
        2.times do # round
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
        end
      end
    end

    it 'is visible', :driver => :selenium_chrome_headless do
      Capybara.page.driver.browser.manage.window.maximize
      Capybara.default_max_wait_time = 90

      login_as("instructor6")
      visit view_grades_path(id: assignment1.id)

      expect(page).to have_selector('#chart_div', visible: true)
    end
  end
end
