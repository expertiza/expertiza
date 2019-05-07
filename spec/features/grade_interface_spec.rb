
describe 'Integration tests for viewing grades:', js: true do
  context 'when checking grade bar chart' do
    # setup roles
    let!(:role1) { create :role_of_student }
    let!(:role2) { create :role_of_instructor }
    let!(:role3) { create :role_of_administrator }
    let!(:role4) { create :role_of_superadministrator }

    # add users
    let!(:instructor) { create :instructor }
    let!(:user1) { create :student, name: "user1" }
    let!(:user2) { create :student, name: "user2" }
    let!(:user3) { create :student, name: "user3" }
    let!(:user4) { create :student, name: "user4" }
    # let!(:users) { [user1 user2 user3 user4] }

    let!(:deadline_right1) do
      rights = %w[NO LATE OK]
      rights.each {|right| create :deadline_right, name: right }
    end

    # add assignment 1
    let!(:assignment1) { create :assignment, id: 1, name: "final123" }
    let!(:assignment_team1) { 2.times { create :assignment_team } }
    let!(:assignment_due_date1) { create :assignment_due_date }

    # add assignment 2
    let!(:assignment2) { create :assignment, id: 2, name: "final456" }
    let!(:assignment_team2) { 2.times { create :assignment_team } }
    let!(:assignment_due_date2) { create(:assignment_due_date, assignment: assignment2) }

    # add assignment 3
    let!(:assignment3) { create :assignment, id: 3, name: "final789" }
    let!(:assignment_team3) { 2.times { create :assignment_team } }
    let!(:assignment_due_date3) { create(:assignment_due_date, assignment: assignment3) }

    # add users to teams
    let!(:team1) do
      create(:team_user, team: Team.find(1), user: User.find_by(name: 'user1'))
      create(:team_user, team: Team.find(1), user: User.find_by(name: 'user2'))
    end
    let!(:team2) do
      create(:team_user, team: Team.find(2), user: User.find_by(name: 'user3'))
      create(:team_user, team: Team.find(2), user: User.find_by(name: 'user4'))
    end

    # add participants to assignments
    let!(:participants) do
      (1..2).each do |assignment_id|
        (1..4).each {|id| create(:participant, user: User.find_by(name: "user#{id}"), assignment: Assignment.find(assignment_id)) }
      end
    end

    # add response_maps
    let!(:review_response_map1) do
      (1..2).each do |assignment_id|
        participant_id = 4
        (1..2).each do |team_id|
          2.times do
            create :review_response_map, reviewee: AssignmentTeam.find(team_id),
                                         reviewer: AssignmentParticipant.find_by(user: User.find_by(name: "user#{participant_id}")),
                                         assignment: Assignment.find(assignment_id)
            participant_id -= 1
          end
        end
      end
    end

    # questionnaires/reviews
    let!(:q_aire) do
      (1..2).each {|i| create(:questionnaire, name: "Test questionnarie#{i}") }
    end

    # assignment_questionnaires
    let!(:assignment1_q_aire) do
      (1..2).each do |assignment_id|
        (1..2).each {|round| create(:assignment_questionnaire, used_in_round: round, assignment: Assignment.find(assignment_id)) }
      end
    end

    # create questions
    let!(:questions) { (1..5).each {|i| create :question, id: i } }

    # qustionnaire/teammate
    let!(:t_aire) { create(:questionnaire, name: "Teammate questionnaire", display_type: "TeammateReview", type: "TeammateReviewQuestionnaire") }
    let!(:assignment1_tq_aire) { create(:assignment_questionnaire, questionnaire: t_aire) }
    let!(:teammate_questions) { 5.times { create :question, questionnaire: t_aire } }

    # add question_advice
    let!(:q_advice) { create :question_advice }

    # add responses
    let!(:data_response) do
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
            (1..5).each do |question_id|
              create(:answers, question: Question.find(question_id), answer: seeded_user, response: Response.find(response_id))
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
          (1..5).each do |question_id|
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
                     ques_id: question_id,
                     ques_questionnaire_id: 1,
                     s_id: index,
                     s_question_id: question_id,
                     s_score: Answer.find(index).answer,
                     s_comments: nil,
                     s_response_id: index)
              index += 1
            end
          end
        end
      end
    end

    it 'is visible' do
      login_as("instructor6")
      visit view_grades_path(id: assignment1.id)

      expect(page).to have_selector('#chart_div', visible: true)
    end
  end

  context 'when the assignment does not have a rubric' do
    it 'displays the average of all assignment grades'
    it 'does not display the rubric statistics for this assignment'
    it 'displays the distribution of all assignment grades'
  end

  context 'when the assignment has a rubric' do
    it 'displays the average of all assignment grades'
    it 'displays the distribution of all assignment grades'
    context 'with only one round' do
      it 'displays the rubric statistics for the assignment'
      it 'displays the "Analyze" tab'
      it 'displays the "Compare" tab as not selectable'
      it 'displays the mean criteria scores on the graph'
      it 'displays "Round 1"'
      it 'does not allow selection of a different round'
      it 'displays all rubric criteria as selected'
      it 'displays "Mean" in the stat selection menu'
      describe 'reactions to rubric statistics' do
        context 'when median is selected' do
          it 'displays "Round 1"'
          it 'displays the median criteria scores on the graph'
          it 'retains selection of all criteria'
          it 'displays "Median" in the stat selection menu'
          describe 'then, when one criterion is deselected' do
            it 'removes the deselected criterion score from the graph'
            describe 'then, when mean is selected' do
              it 'retains the previously selected criteria'
              it 'displays the selected means on the graph'
              describe 'then, when more than one criterion is deselected' do
                it 'removes the deselected criteria from the graph'
                describe 'then, when all criteria are deselected' do
                  it 'removes all mean criteria scores from the graph'
                  describe 'then, when median is selected' do
                    it 'retains a blank graph'
                  end
                end
              end
            end
          end
        end
      end
    end
    context 'with more than one round' do
      it 'displays the rubric statistics for the assignment'
      it 'displays the "Analyze" tab'
      it 'displays the "Compare" tab as not selectable'
      it 'displays the mean criteria scores on the graph'
      it 'displays "Round 1"'
      it 'displays "Round 1" in the round selection menu'
      it 'displays all rubric criteria as selected'
      it 'displays "Mean" in the stat selection menu'
      describe 'reactions to rubric statistics' do
        context 'when a different round is selected' do
          it 'displays the chosen round in the round selection menu'
          it 'displays all rubric criteria as selected'
          it 'displays the mean criteria scores on the graph'
          describe 'and median is selected' do
            it 'displays the median criteria scores on the graph'
            it 'retains selection of all criteria'
            it 'displays "Median" in the stat selection menu'
            describe 'then, when one criterion is deselected' do
              it 'removes the deselected criterion score from the graph'
            end
          end
        end
      end
    end

    context 'when more than one assignment has rubrics' do
      it 'displays the "Analyze" tab'
      describe 'two assignments with rubrics' do
        context 'when the criteria are not compatible' do
          it 'displays the "Compare" tab as not selectable'
        end
        context 'when the criteria are compatible' do
          it 'displays the "Compare" tab as selectable'
          describe 'then, when the Compare tab is selected' do
            it 'displays the "Assignment" drop down menu'
            it 'displays both rubric averages'
            describe 'then, when a criterion is deselected' do
              it 'removes the deselected criterion from the graph'
              describe 'then, when median is selected' do
                it 'displays the median criteria scores on the graph'
                it 'retains the previously selected criteria'
                it 'displays "Median" in the stat selection menu'
              end
            end
          end
        end
      end
    end
  end
end
