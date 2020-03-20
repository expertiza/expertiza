require 'spec_helper'
require 'rails_helper'

describe ReviewMappingHelper, type: :helper do

  describe 'get_team_colour' do
    before(:each) do
      @assignment = create(:assignment, name: 'get_team_colour_test', created_at: DateTime.now.in_time_zone - 13.day)
    end

    it 'should return \'red\' if response_map does not exist in Responses' do
      response_map = create(:review_response_map)

      colour = get_team_colour(response_map)
      expect(colour).to eq('red')
    end

    it 'should return \'brown\' if reviewer (and its review_grade) both exist' do
      review_grade = create(:review_grade)
      reviewer = create(:participant, review_grade: review_grade)
      response_map = create(:review_response_map, reviewer: reviewer)
      create(:response, response_map: response_map)

      colour = get_team_colour(response_map)
      expect(colour).to eq('brown')
    end

    it 'should not return \'blue\' if a review was not submitted in each round' do
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 1)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 2)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 3)
      reviewer = create(:participant, review_grade: nil)
      response_map = create(:review_response_map, reviewer: reviewer)
      create(:response, response_map: response_map)

      colour = get_team_colour(response_map)
      expect(colour).not_to eq('blue')
    end

    it 'should return \'green\' if the submission link does not exist' do
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')
      reviewer = create(:participant, review_grade: nil)
      response_map = create(:review_response_map, reviewer: reviewer)
      create(:response, response_map: response_map)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 1)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 2)

      colour = get_team_colour(response_map)
      expect(colour).to eq('green')
    end

    it 'should return \'green\' if the submission link is not a wiki link' do
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')
      create(:assignment_team, assignment: @assignment)
      reviewer = create(:participant, review_grade: nil)
      reviewee = create(:assignment_team)
      response_map = create(:review_response_map, reviewer: reviewer, reviewee: reviewee)
      create(:submission_record, assignment_id: @assignment.id, team_id: reviewee.id, operation: 'Submit Hyperlink', content: 'not a wiki link')
      create(:response, response_map: response_map)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 1)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 2)

      colour = get_team_colour(response_map)
      expect(colour).to eq('green')
    end

    it 'should return \'purple\' if review was submitted within each round' do
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')
      create(:assignment_team, assignment: @assignment)
      reviewer = create(:participant, review_grade: nil)
      reviewee = create(:assignment_team)
      response_map = create(:review_response_map, reviewer: reviewer, reviewee: reviewee)
      create(:submission_record, assignment_id: @assignment.id, team_id: reviewee.id, operation: 'Submit Hyperlink', content: 'not a wiki link')
      create(:submission_record, assignment_id: @assignment.id, team_id: reviewee.id, operation: 'Submit Hyperlink', content: 'not a wiki link', created_at: DateTime.now.in_time_zone + 4.day)
      create(:response, response_map: response_map)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 1, due_at: DateTime.now.in_time_zone + 3.day)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 2, due_at: DateTime.now.in_time_zone + 6.day)

      colour = get_team_colour(response_map)
      expect(colour).to eq('purple')
    end

    it 'should return \'purple\' if the submitted wiki link has been updated since the due date for that round' do
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')
      reviewer = create(:participant, review_grade: nil)
      reviewee = create(:assignment_team, assignment: @assignment)
      response_map = create(:review_response_map, reviewer: reviewer, reviewee: reviewee)
      create(:submission_record, assignment_id: @assignment.id, team_id: reviewee.id, operation: 'Submit Hyperlink', content: 'https://wiki.archlinux.org/', created_at: DateTime.now.in_time_zone - 7.day)
      create(:response, response_map: response_map)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 1, due_at: DateTime.now.in_time_zone - 5.day)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 2, due_at: DateTime.now.in_time_zone + 6.day)

      colour = get_team_colour(response_map)
      expect(colour).to eq('purple')
    end
  end

  describe 'obtain_team_colour' do
    before(:each) do
      @assignment = create(:assignment, name: 'obtain_team_colour_test', num_reviews: 3, created_at: DateTime.now.in_time_zone - 13.day)

    end
    it 'should return \'purple\' if last review was submitted within the round' do
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')
      reviewer = create(:participant, review_grade: nil)
      reviewee = create(:assignment_team, assignment: @assignment)
      response_map = create(:review_response_map, reviewer: reviewer, reviewee: reviewee)
      create(:submission_record, assignment_id: @assignment.id, team_id: reviewee.id, operation: 'Submit Hyperlink', content: 'https://wiki.archlinux.org/', created_at: DateTime.now.in_time_zone - 7.day)
      create(:response, response_map: response_map)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 1, due_at: DateTime.now.in_time_zone - 5.day)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 2, due_at: DateTime.now.in_time_zone + 6.day)

      assignment_created = @assignment.created_at
      assignment_due_dates = DueDate.where(parent_id: response_map.reviewed_object_id)
      colour = obtain_team_colour(response_map,assignment_created,assignment_due_dates)
      expect(colour).to eq('purple')

    end
    it 'should return \'green\' if the submission link does not exist' do
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')
      reviewer = create(:participant, review_grade: nil)
      response_map = create(:review_response_map, reviewer: reviewer)
      create(:response, response_map: response_map)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 1)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 2)

      assignment_created = @assignment.created_at
      assignment_due_dates = DueDate.where(parent_id: response_map.reviewed_object_id)
      colour = obtain_team_colour(response_map,assignment_created,assignment_due_dates)
      expect(colour).to eq('green')
    end

  end

  describe 'link_updated_since_last?' do
    before(:each) do
      @round = 2

      assignment = create(:assignment, name: 'link_updated_since_last_test', created_at: DateTime.now.in_time_zone - 13.day)
      reviewer = create(:participant, review_grade: nil)
      reviewee = create(:assignment_team, assignment: assignment)
      response_map = create(:review_response_map, reviewer: reviewer, reviewee: reviewee)
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')
      create(:assignment_due_date, round: 1, due_at: DateTime.now.in_time_zone + 1.day)
      create(:assignment_due_date, round: 2, due_at: DateTime.now.in_time_zone + 5.day)
      @due_dates = DueDate.where(parent_id: response_map.reviewed_object_id)
    end

    it 'should return false if submission link was not updated between the last round and the current one' do
      link_updated_at = DateTime.now.in_time_zone - 3.day

      result = link_updated_since_last?(@round, @due_dates, link_updated_at)
      expect(result).to eq(false)
    end

    it 'should return true if submission link was updated between the last round and the current one' do
      link_updated_at = DateTime.now.in_time_zone + 3.day

      result = link_updated_since_last?(@round, @due_dates, link_updated_at)
      expect(result).to eq(true)
    end
    
  end
  
  describe 'response_for_each_round?' do
    before(:each) do
      @assignment = create(:assignment, name: 'response_for_each_round_test', created_at: DateTime.now.in_time_zone - 13.day)
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 1)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 2)
    end

    it 'should return false if the number of responses does not equal the total number of rounds' do
      response_map = create(:review_response_map)
      create(:response, response_map: response_map, round: 1)

      result = response_for_each_round?(response_map)
      expect(result).to be(false)
    end

    it 'should return true if the number of responses equals the total number of rounds' do
      response_map = create(:review_response_map)
      create(:response, response_map: response_map, round: 1)
      create(:response, response_map: response_map, round: 2)

      result = response_for_each_round?(response_map)
      expect(result).to be(true)
    end

  end
  
  describe 'submitted_within_round?' do
    before(:each) do
      @round = 1

      assignment = create(:assignment, name: 'submitted_within_round_test', created_at: DateTime.now.in_time_zone - 13.day)
      @assignment_created = assignment.created_at

      reviewer = create(:participant, review_grade: nil)
      reviewee = create(:assignment_team, assignment: assignment)
      @response_map = create(:review_response_map, reviewer: reviewer, reviewee: reviewee)

      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')
      create(:assignment_due_date, assignment: assignment, parent_id: assignment.id, round: 1, due_at: DateTime.now.in_time_zone - 5.day)
      @assignment_due_dates = DueDate.where(parent_id: @response_map.reviewed_object_id)

      @submission = create(:submission_record, assignment_id: assignment.id, team_id: reviewee.id, operation: 'Submit Hyperlink')
    end

    it 'should return false if the submission was made outside of the submission window for the given round' do
      @submission.created_at = DateTime.now.in_time_zone + 7.day
      @submission.save

      result = submitted_within_round?(@round, @response_map, @assignment_created, @assignment_due_dates)
      expect(result).to be(false)
    end

    it 'should return true if the submission was made within the submission window for the given round' do
      @submission.created_at = DateTime.now.in_time_zone - 7.day
      @submission.save

      result = submitted_within_round?(@round, @response_map, @assignment_created, @assignment_due_dates)
      expect(result).to be(true)
    end

  end

  describe 'submitted_hyperlink' do
    before(:each) do
      @round = 1
      assignment = create(:assignment, name: 'submitted_within_round_test', created_at: DateTime.now.in_time_zone - 13.day)
      @assignment_created = assignment.created_at
      reviewer = create(:participant, review_grade: nil)
      reviewee = create(:assignment_team, assignment: assignment)
      @response_map = create(:review_response_map, reviewer: reviewer, reviewee: reviewee)
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')
      create(:assignment_due_date, assignment: assignment, parent_id: assignment.id, round: 1, due_at: DateTime.now.in_time_zone - 5.day)
      @assignment_due_dates = DueDate.where(parent_id: @response_map.reviewed_object_id)
      @submission = create(:submission_record, assignment_id: assignment.id, team_id: reviewee.id, operation: 'Submit Hyperlink')
    end

    it 'should return nil if the hyperlink doesnt exist' do
      @submission.created_at = DateTime.now.in_time_zone - 7.day
      @submission.content = nil
      @submission.save
      hyper_link = submitted_hyperlink(@round, @response_map, @assignment_created, @assignment_due_dates)
      expect(hyper_link).to eq(nil)
    end

    it 'should return hyperlink if it was submitted' do
      @submission.created_at = DateTime.now.in_time_zone - 7.day
      @submission.content = 'www.test.com'
      @submission.save
      hyper_link = submitted_hyperlink(@round, @response_map, @assignment_created, @assignment_due_dates)
      expect(hyper_link).to eq('www.test.com')
    end
  end

  describe 'get_link_updated_at' do
    it 'should return true if site was updated' do
      link = 'https://wiki.archlinux.org/'
      time_updated = get_link_updated_at(link)
      expect(time_updated).to be_a_kind_of(Time)
    end
  end

  describe 'get_data_for_review_report' do
    before(:each) do
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')
      @assignment = create(:assignment, name: 'get_data_for_review_report_test', created_at: DateTime.now.in_time_zone - 13.day)
      @reviewer = create(:participant, review_grade: nil)
      @type = 'ReviewResponseMap'
    end

    it 'should return the correct number of response maps' do
      reviewee1 = create(:assignment_team, assignment: @assignment)
      reviewee2 = create(:assignment_team, assignment: @assignment)
      @response_map = create(:review_response_map, reviewer: @reviewer, reviewee: reviewee1, type: @type)
      @response_map = create(:review_response_map, reviewer: @reviewer, reviewee: reviewee2, type: @type)

      response_maps, rspan = get_data_for_review_report(@assignment.id,@reviewer.id,@type)
      expect(response_maps.length).to be(2)
      expect(rspan).to be(2)
    end

    end


  describe 'get_team_reviewed_link_name' do
    before(:each) do
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')
      @assignment = create(:assignment, name: 'get_team_reviewed_link_name_test', created_at: DateTime.now.in_time_zone - 13.day)

    end

    it 'should return the full name of the user if team consists of one person and last response is submitted' do
      user = create(:student)
      reviewee = create(:assignment_team, assignment: @assignment)
      create(:team_user, user: user, team: reviewee)

      response_map = create(:review_response_map)
      create(:response, response_map: response_map, is_submitted: true)
      team_reviewed_link_name = get_team_reviewed_link_name(1,response_map.response,reviewee.id)

      expect(team_reviewed_link_name).to eq TeamsUser.where(team_id: reviewee.id).first.user.fullname

    end


    it 'should return the full name of the user in brackets if team consists of one person and last response is not submitted' do
      user = create(:student)
      reviewee = create(:assignment_team, assignment: @assignment)
      create(:team_user, user: user, team: reviewee)

      response_map = create(:review_response_map)
      create(:response, response_map: response_map, is_submitted: false)
      team_reviewed_link_name = get_team_reviewed_link_name(1,response_map.response,reviewee.id)

      expect(team_reviewed_link_name).to eq "(" + TeamsUser.where(team_id: reviewee.id).first.user.fullname + ")"

    end

    it 'should return the team name if team consists of more than one person and last response is submitted' do
      reviewee = create(:assignment_team, assignment: @assignment, name: "test_team")

      response_map = create(:review_response_map)
      create(:response, response_map: response_map, is_submitted: true)
      team_reviewed_link_name = get_team_reviewed_link_name(3,response_map.response,reviewee.id)

      expect(team_reviewed_link_name).to eq reviewee.name
    end

    it 'should return the team name in brackets if team consists of more than one person and last response is not submitted' do
      reviewee = create(:assignment_team, assignment: @assignment, name: "test_team")

      response_map = create(:review_response_map)
      create(:response, response_map: response_map, is_submitted: false)
      team_reviewed_link_name = get_team_reviewed_link_name(3,response_map.response,reviewee.id)

      expect(team_reviewed_link_name).to eq "(" + reviewee.name + ")"
    end

  end

  describe ReviewMappingHelper::StudentReviewStrategy do

    describe 'reviews_per_team' do
      it 'should return the number of reviews expected from each team' do
        strategy = ReviewMappingHelper::StudentReviewStrategy.new(Array.new(20), Array.new(5), 3)

        reviews = strategy.reviews_per_team

        expect(reviews).to be(12)
      end

      it 'should round the number of reviews up to the nearest integer (if decimal is >= .5)' do
        strategy = ReviewMappingHelper::StudentReviewStrategy.new(Array.new(21), Array.new(5), 3)

        reviews = strategy.reviews_per_team

        expect(reviews).to be(13)
      end

      it 'should round the number of reviews down to the nearest integer (if decimal is < .5)' do
        strategy = ReviewMappingHelper::StudentReviewStrategy.new(Array.new(19), Array.new(5), 3)

        reviews = strategy.reviews_per_team

        expect(reviews).to be(11)
      end

    end

    describe 'reviews_needed' do
      it 'should return the total number of reviews needed for the assignment' do
        strategy = ReviewMappingHelper::StudentReviewStrategy.new(Array.new(20), Array.new(5), 3)

        reviews = strategy.reviews_needed

        expect(reviews).to be(60)
      end

    end

    describe 'reviews_per_student' do
      it 'should return the number of reviews each student is expected to do' do
        strategy = ReviewMappingHelper::StudentReviewStrategy.new(Array.new(20), Array.new(5), 3)

        reviews = strategy.reviews_per_student

        expect(reviews).to be(3)
      end

    end

  end

  describe ReviewMappingHelper::TeamReviewStrategy do

    describe 'reviews_per_team' do
      it 'should return the number of reviews expected from each team' do
        strategy = ReviewMappingHelper::TeamReviewStrategy.new(Array.new(20), Array.new(5), 3)

        reviews = strategy.reviews_per_team

        expect(reviews).to be(3)
      end

    end

    describe 'reviews_needed' do
      it 'should return the total number of reviews needed for the assigment' do
        strategy = ReviewMappingHelper::TeamReviewStrategy.new(Array.new(20), Array.new(5), 3)

        reviews = strategy.reviews_needed

        expect(reviews).to be(15)
      end

    end

    describe 'reviews_per_student' do
      it 'should return the number of reviews each team is expected to do' do
        strategy = ReviewMappingHelper::TeamReviewStrategy.new(Array.new(5), Array.new(5), 3)

        reviews = strategy.reviews_per_student

        expect(reviews).to be(3)
      end

      it 'should round the number of reviews up to the nearest integer (if decimal is >= .5)' do
        strategy = ReviewMappingHelper::TeamReviewStrategy.new(Array.new(5), Array.new(6), 3)

        reviews = strategy.reviews_per_student

        expect(reviews).to be(4)
      end

      it 'should round the number of reviews down to the nearest integer (if decimal is < .5)' do
        strategy = ReviewMappingHelper::TeamReviewStrategy.new(Array.new(5), Array.new(4), 3)

        reviews = strategy.reviews_per_student

        expect(reviews).to be(2)
      end

    end

  end


  describe 'sort_reviewer_by_review_volume_desc' do
    before(:each) do
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')

      @assignment = create(:assignment, name: 'get_awarded_review_score_test', created_at: DateTime.now.in_time_zone - 13.day)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 1)

      questionnaire_1 = create(:questionnaire)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: questionnaire_1, used_in_round: 1)
      @question_1 = create(:question, questionnaire: questionnaire_1)

      @reviewer_1 = create(:participant, review_grade: nil)
      @reviewer_2 = create(:participant, review_grade: nil)
      @reviewer_3 = create(:participant, review_grade: nil)
      reviewee = create(:assignment_team)

      @response_map_1 = create(:review_response_map, reviewer: @reviewer_1, reviewee: reviewee, assignment: @assignment)
      @response_map_2 = create(:review_response_map, reviewer: @reviewer_2, reviewee: reviewee, assignment: @assignment)
      @response_map_3 = create(:review_response_map, reviewer: @reviewer_3, reviewee: reviewee, assignment: @assignment)

    end

    it 'should sort the reviewers by review volume when additional comment is provided in all responses' do
      response_1 = create(:response, response_map: @response_map_1, round: 1, additional_comment: "Abc")
      response_2 = create(:response, response_map: @response_map_2, round: 1, additional_comment: "Abcde")
      response_3 = create(:response, response_map: @response_map_3, round: 1, additional_comment: "Abcde")

      create(:answer, question: @question_1, response: response_1, comments: "Is this it?")
      create(:answer, question: @question_1, response: response_2, comments: "I dont think this is it?")
      create(:answer, question: @question_1, response: response_3, comments: "This may be it?")

      @reviewers = []
      @reviewers << Participant.find(@reviewer_1.id)
      @reviewers << Participant.find(@reviewer_2.id)
      @reviewers << Participant.find(@reviewer_3.id)

      sort_reviewer_by_review_volume_desc()
      expect(@reviewers[0]).to eq @reviewer_2
      expect(@reviewers[1]).to eq @reviewer_3
      expect(@reviewers[2]).to eq @reviewer_1

    end

    it 'should sort the reviewers by review volume when additional comment is not provided in any/some response' do
      response_1 = create(:response, response_map: @response_map_1, round: 1)
      response_2 = create(:response, response_map: @response_map_2, round: 1)
      response_3 = create(:response, response_map: @response_map_3, round: 1)

      create(:answer, question: @question_1, response: response_1, comments: "Is this it?")
      create(:answer, question: @question_1, response: response_2, comments: "I dont think this is it?")
      create(:answer, question: @question_1, response: response_3, comments: "This may be it?")

      @reviewers = []
      @reviewers << Participant.find(@reviewer_1.id)
      @reviewers << Participant.find(@reviewer_2.id)
      @reviewers << Participant.find(@reviewer_3.id)

      sort_reviewer_by_review_volume_desc()
      expect(@reviewers[0]).to eq @reviewer_2
      expect(@reviewers[1]).to eq @reviewer_3
      expect(@reviewers[2]).to eq @reviewer_1

    end
  end


  describe 'calcutate_average_author_feedback_score' do
    before(:each) do
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')

      @assignment = create(:assignment, name: 'get_awarded_review_score_test', created_at: DateTime.now.in_time_zone - 13.day)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 1)

      user = create(:student)
      @reviewee = create(:assignment_team, assignment: @assignment)
      create(:team_user, user: user, team: @reviewee)
      reviewer = create(:participant, assignment: @assignment, user: user)

      @response_map = create(:review_response_map, reviewer: reviewer, reviewee: @reviewee, assignment: @assignment)


      questionnaire_1 = create(:questionnaire, min_question_score: 0, max_question_score: 5)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: questionnaire_1, used_in_round: 1)
      question_1 = create(:question, questionnaire: questionnaire_1)
      question_2 = create(:question, questionnaire: questionnaire_1)

      response_1 = create(:response, response_map: @response_map, round: 1)

      create(:answer, question: question_1, response: response_1, answer: 2)
      create(:answer, question: question_2, response: response_1, answer: 4 )

    end

    it 'returns the average author feedback score if maximum team size is equal to 1' do
      max_team_size = 1
      author_feedback_avg_score = calcutate_average_author_feedback_score(@assignment.id, max_team_size, @response_map.id, @reviewee.id)
      expect(author_feedback_avg_score).to eq "6 / 10"
    end

    it 'returns empty response if maximum team size is not 1' do
      max_team_size = 3
      author_feedback_avg_score = calcutate_average_author_feedback_score(@assignment.id, max_team_size, @response_map.id, @reviewee.id)
      expect(author_feedback_avg_score).to eq "-- / --"
    end

  end

  describe 'initialize_chart_elements' do
    before(:each) do
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')

      @assignment = create(:assignment, name: 'get_awarded_review_score_test', created_at: DateTime.now.in_time_zone - 13.day)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 1)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 2)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 3)

      questionnaire_1 = create(:questionnaire)
      questionnaire_2 = create(:questionnaire)
      questionnaire_3 = create(:questionnaire)

      create(:assignment_questionnaire, assignment: @assignment, questionnaire: questionnaire_1, used_in_round: 1)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: questionnaire_2, used_in_round: 2)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: questionnaire_3, used_in_round: 3)

      question_1_1 = create(:question, questionnaire: questionnaire_1)
      question_1_2 = create(:question, questionnaire: questionnaire_1)

      question_2_1 = create(:question, questionnaire: questionnaire_2)
      question_2_2 = create(:question, questionnaire: questionnaire_2)

      question_3_1 = create(:question, questionnaire: questionnaire_3)
      question_3_2 = create(:question, questionnaire: questionnaire_3)

      @reviewer_1 = create(:participant, review_grade: nil)
      @reviewer_2 = create(:participant, review_grade: nil)

      reviewee = create(:assignment_team)

      @response_map_1 = create(:review_response_map, reviewer: @reviewer_1, reviewee: reviewee, assignment: @assignment)
      @response_map_2 = create(:review_response_map, reviewer: @reviewer_2, reviewee: reviewee, assignment: @assignment)

      response_1_1 = create(:response, response_map: @response_map_1, round: 1, additional_comment: "Some Comment")
      response_1_2 = create(:response, response_map: @response_map_1, round: 2, additional_comment: "Some Comment")
      response_1_3 = create(:response, response_map: @response_map_1, round: 3, additional_comment: "Some Comment")

      response_2_1 = create(:response, response_map: @response_map_2, round: 1, additional_comment: "Some Comment")
      response_2_2 = create(:response, response_map: @response_map_2, round: 2, additional_comment: "Some Comment")
      response_2_3 = create(:response, response_map: @response_map_2, round: 3, additional_comment: "Some Comment")

      create(:answer, question: question_1_1, response: response_1_1, comments: "Lebron is the goat ")
      create(:answer, question: question_1_2, response: response_1_1, comments: "He can gaurd 1 to 5 ")
      create(:answer, question: question_2_1, response: response_1_2, comments: "Elite ball handler ")
      create(:answer, question: question_2_2, response: response_1_2, comments: "Elite Scorer ")
      create(:answer, question: question_3_1, response: response_1_3, comments: "DPOY runner up ")
      create(:answer, question: question_3_2, response: response_1_3, comments: "Most complete player ever ")

      create(:answer, question: question_1_1, response: response_2_1, comments: "MJ is the goat no question ")
      create(:answer, question: question_1_2, response: response_2_1, comments: "Greatest scorer of all time ")
      create(:answer, question: question_2_1, response: response_2_2, comments: "Top 5 defenders ever ")
      create(:answer, question: question_2_2, response: response_2_2, comments: "Averaged 30 plus in the playoffs ")
      create(:answer, question: question_3_1, response: response_2_3, comments: "Insane finals record ")
      create(:answer, question: question_3_2, response: response_2_3, comments: "Six time Finals MVP ")
    end

    it 'Should initialize the chart elements (reviewer variables) with the correct response volumes' do

      @reviewers = []
      @reviewers << Participant.find(@reviewer_1.id)
      @reviewers << Participant.find(@reviewer_2.id)

      sort_reviewer_by_review_volume_desc()

      return_array_0 = []
      return_array_1 = []

      return_array_0 = initialize_chart_elements(@reviewers[0])
      return_array_1 = initialize_chart_elements(@reviewers[1])

      labels_0 = return_array_0[0]
      labels_1 = return_array_1[0]
      reviewer_data_0 = return_array_0[1]
      reviewer_data_1 = return_array_1[1]
      all_reviewers_data_0 = return_array_0[2]
      all_reviewers_data_1 = return_array_1[2]

      expect(all_reviewers_data_0).to match_array all_reviewers_data_1
      expect(labels_0).to match_array ["1st", "2nd", "3rd", "Total"]
      expect(labels_1).to match_array ["1st", "2nd", "3rd", "Total"]
      expect(reviewer_data_0).to match_array [13, 10, 9, 10]
      expect(reviewer_data_1).to match_array [10, 7, 9, 8]

    end
  end

end
