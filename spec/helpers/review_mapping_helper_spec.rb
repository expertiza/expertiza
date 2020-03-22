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
  
  describe 'check_submission_state' do
    before(:each) do
      @assignment = create(:assignment, name: 'get_team_colour_test', created_at: DateTime.now.in_time_zone - 13.day)
    end

    it 'should return \'purple\' if the was submitted within the round' do
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
      round = 2
      colour = check_submission_state(response_map, assignment_created, assignment_due_dates, round)
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
    round = 2
    colour = check_submission_state(response_map, assignment_created, assignment_due_dates, round)
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

end
