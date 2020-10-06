require 'spec_helper'
require 'rails_helper'

describe ReviewMappingHelper, type: :helper do
  describe 'get_team_color' do
    before(:each) do
      @assignment = create(:assignment, created_at: DateTime.now.in_time_zone - 13.day)
      @reviewer = create(:participant, review_grade: nil)
      @reviewee = create(:assignment_team)
      @reviewee_with_assignment = create(:assignment_team, assignment: @assignment)
      @response_map = create(:review_response_map, reviewer: @reviewer)
    end

    it 'color should be red if response_map does not exist' do
      response_map_dne = create(:review_response_map)

      color = get_team_colour(response_map_dne)
      expect(color).to eq('red')
    end

    it 'color should be blue if the a review was submitted for each round' do
      # deadline_right inspired from bookmark_review_spec
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')

      # make a team for the assignment
      create(:assignment_team, assignment: @assignment)

      response_map_with_reviewee = create(:review_response_map, reviewer: @reviewer, reviewee: @reviewee)

      create(:submission_record, assignment_id: @assignment.id, team_id: @reviewee.id, operation: 'Submit Hyperlink', content: 'random link')

      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 1)

      create(:response, response_map: response_map_with_reviewee)

      color = get_team_colour(response_map_with_reviewee)
      expect(color).to eq('blue')
    end

    it 'color should NOT be blue if the a review was NOT submitted for each round' do
      # deadline_right inspired from bookmark_review_spec
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')

      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 1)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 2)

      create(:response, response_map: @response_map)

      color = get_team_colour(@response_map)
      expect(color).not_to eq('blue')
    end

    it 'color should be brown if the review and review_grade exist' do
      review_grade = create(:review_grade)
      reviewer_with_grade = create(:participant, review_grade: review_grade)
      response_map_with_grade_reviewer = create(:review_response_map, reviewer: reviewer_with_grade)
      create(:response, response_map: response_map_with_grade_reviewer)

      color = get_team_colour(response_map_with_grade_reviewer)
      expect(color).to eq('brown')
    end

    it 'color should be green if the submission link is non-existent' do
      # deadline_right inspired from bookmark_review_spec
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')

      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 1)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 2)

      create(:response, response_map: @response_map)

      color = get_team_colour(@response_map)
      expect(color).to eq('green')
    end

    it 'color should be green if the submission link is NOT a link to a Expertiza wiki' do
      # deadline_right inspired from bookmark_review_spec
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')

      # make a team for the assignment
      create(:assignment_team, assignment: @assignment)

      response_map_with_reviewee = create(:review_response_map, reviewer: @reviewer, reviewee: @reviewee)

      create(:submission_record, assignment_id: @assignment.id, team_id: @reviewee.id, operation: 'Submit Hyperlink', content: 'random link')

      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 1)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 2)

      create(:response, response_map: response_map_with_reviewee)

      color = get_team_colour(response_map_with_reviewee)
      expect(color).to eq('green')
    end

    it 'color should be purple if review were submitted for each round (on time)' do
      # deadline_right inspired from bookmark_review_spec
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')

      # make a team for the assignment
      create(:assignment_team, assignment: @assignment)

      response_map_with_reviewee = create(:review_response_map, reviewer: @reviewer, reviewee: @reviewee)

      create(:submission_record, assignment_id: @assignment.id, team_id: @reviewee.id, operation: 'Submit Hyperlink', content: 'random link')
      create(:submission_record, assignment_id: @assignment.id, team_id: @reviewee.id, operation: 'Submit Hyperlink', content: 'random link', created_at: DateTime.now.in_time_zone + 4.day)

      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 1, due_at: DateTime.now.in_time_zone + 3.day)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 2, due_at: DateTime.now.in_time_zone + 6.day)

      create(:response, response_map: response_map_with_reviewee)

      color = get_team_colour(response_map_with_reviewee)
      expect(color).to eq('purple')
    end

    it 'color should be purple if submission link has been updated since due date for a specified round' do
      # deadline_right inspired from bookmark_review_spec
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')

      response_map_with_reviewee = create(:review_response_map, reviewer: @reviewer, reviewee: @reviewee_with_assignment)

      create(:submission_record, assignment_id: @assignment.id, team_id: @reviewee_with_assignment.id, operation: 'Submit Hyperlink', content: 'https://wiki.archlinux.org/', created_at: DateTime.now.in_time_zone - 7.day)

      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 1, due_at: DateTime.now.in_time_zone - 5.day)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 2, due_at: DateTime.now.in_time_zone + 6.day)

      create(:response, response_map: response_map_with_reviewee)

      color = get_team_colour(response_map_with_reviewee)
      expect(color).to eq('purple')
    end
  end

  describe 'get_each_review_and_feedback_response' do
    before(:each) do
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')

      @assignment = create(:assignment, created_at: DateTime.now.in_time_zone - 13.day)

      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 1)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 2)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 3)

      # @id is used in the method call, need to assign it to the assignment id
      @id = @assignment.id

      student = create(:student)
      @reviewee = create(:assignment_team, assignment: @assignment)
      @reviewer = create(:participant, assignment: @assignment, user: student)

      create(:team_user, user: student, team: @reviewee)

      @response_map_1 = create(:review_response_map, reviewer: @reviewer)
      @response_map_2 = create(:review_response_map, reviewer: @reviewer)
      @response_map_3 = create(:review_response_map, reviewer: @reviewer)

      @response_1 = create(:response, response_map: @response_map_1, round: 1)
      @response_2 = create(:response, response_map: @response_map_2, round: 2)

      @response_list = [@response_1, @response_2]

      feedback_response_map_1 = FeedbackResponseMap.create(reviewed_object_id: @response_1.id, reviewer_id: @reviewer.id)
      feedback_response_map_2 = FeedbackResponseMap.create(reviewed_object_id: @response_2.id, reviewer_id: @reviewer.id)

      @feedback_response_map_list = [feedback_response_map_1, feedback_response_map_2]

      @all_review_response_ids = [@response_1.id, @response_2.id]
    end

    it 'should return the number of responses given in round 1 reviews' do
      get_each_review_and_feedback_response_map(@reviewer)

      # rspan means the all peer reviews one student received, including unfinished one
      # retrieved from method call in review_mapping_helper.rb file
      expect(@rspan_round_one).to eq 1
    end

    it 'should return the number of responses given in round 2 reviews' do
      get_each_review_and_feedback_response_map(@reviewer)

      # rspan means the all peer reviews one student received, including unfinished one
      # retrieved from method call in review_mapping_helper.rb file
      expect(@rspan_round_two).to eq 1
    end

    it 'should return the number of responses given in round 3 reviews' do
      # have to add in third response, did not in before action for nil scenario
      @response_3 = create(:response, response_map: @response_map_3, round: 3)
      @response_list << @response_3
      @feedback_response_map_list << FeedbackResponseMap.create(reviewed_object_id: @response_3.id, reviewer_id: @reviewer.id)
      @all_review_response_ids << @response_3.id

      get_each_review_and_feedback_response_map(@reviewer)

      # rspan means the all peer reviews one student received, including unfinished one
      # retrieved from method call in review_mapping_helper.rb file
      expect(@rspan_round_three).to eq 1
    end

    it 'should return 0 responses for no round 3 reviews' do
      # no feedback responses set before method call
      get_each_review_and_feedback_response_map(@reviewer)

      # rspan means the all peer reviews one student received, including unfinished one
      # retrieved from method call in review_mapping_helper.rb file
      expect(@rspan_round_three).to eq 0
    end
  end

  # feedback_response_map_record is called within get_each_review_and_feedback_response_map
  describe 'feedback_response_map_record' do
    before(:each) do
      @reviewer = create(:participant)

      @response_map_1 = create(:review_response_map, reviewer: @reviewer)
      @response_map_2 = create(:review_response_map, reviewer: @reviewer)
      @response_map_3 = create(:review_response_map, reviewer: @reviewer)

      @review_response_map_ids = [@response_map_1.id, @response_map_2.id, @response_map_3.id]

      @response_1 = create(:response, response_map: @response_map_1, round: 1)
      @response_2 = create(:response, response_map: @response_map_2, round: 2)
      @response_3 = create(:response, response_map: @response_map_3, round: 3)

      FeedbackResponseMap.create(reviewed_object_id: @response_1.id, reviewer_id: @reviewer.id)
      FeedbackResponseMap.create(reviewed_object_id: @response_2.id, reviewer_id: @reviewer.id)
      FeedbackResponseMap.create(reviewed_object_id: @response_3.id, reviewer_id: @reviewer.id)

      @all_review_response_ids_round_one = [@response_1.id]
      @all_review_response_ids_round_two = [@response_2.id]
      @all_review_response_ids_round_three = [@response_3.id]

      feedback_response_map_record(@reviewer)
    end

    it 'should return response_map id tied to the feedback provided in round 1' do
      expect(@feedback_response_maps_round_one.first.reviewed_object_id).to eq(@response_1.id)
    end

    it 'should return response_map id tied to the feedback provided in round 2' do
      expect(@feedback_response_maps_round_two.first.reviewed_object_id).to eq(@response_2.id)
    end

    it 'should return response_map id tied to the feedback provided in round 3' do
      expect(@feedback_response_maps_round_three.first.reviewed_object_id).to eq(@response_3.id)
    end
  end

  describe 'check_submission_state' do
    before(:each) do
      @assignment = create(:assignment, created_at: DateTime.now.in_time_zone - 13.day)
      @reviewer = create(:participant, review_grade: nil)
      @reviewee = create(:assignment_team, assignment: @assignment)
      @response_map = create(:review_response_map, reviewer: @reviewer, reviewee: @reviewee)
    end

    it 'should return green color if the submitted link is not a wiki link' do
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')
      create(:submission_record, assignment_id: @assignment.id, team_id: @reviewee.id, operation: 'Submit Hyperlink', content: 'https://google.com/', created_at: DateTime.now.in_time_zone - 7.day)
      create(:response, response_map: @response_map)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 1, due_at: DateTime.now.in_time_zone - 5.day)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 2, due_at: DateTime.now.in_time_zone + 6.day)

      assignment_created = @assignment.created_at
      assignment_due_dates = DueDate.where(parent_id: @response_map.reviewed_object_id)
      round = 2
      color = []
      resp_color = check_submission_state(@response_map, assignment_created, assignment_due_dates, round, color)
      expect(resp_color).to eq(['green'])
    end

    it 'should return green color if the submission link is not present' do
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')
      create(:response, response_map: @response_map)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 1)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 2)

      assignment_created = @assignment.created_at
      assignment_due_dates = DueDate.where(parent_id: @response_map.reviewed_object_id)
      round = 2
      color = []
      resp_color = check_submission_state(@response_map, assignment_created, assignment_due_dates, round, color)
      expect(resp_color).to eq(['green'])
    end

    it 'should return green color if the assignment was not submitted within the round' do
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')
      create(:submission_record, assignment_id: @assignment.id, team_id: @reviewee.id, operation: 'Submit Hyperlink', content: 'https://wiki.archlinux.org/', created_at: DateTime.now.in_time_zone + 7.day)
      create(:response, response_map: @response_map)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 1, due_at: DateTime.now.in_time_zone - 5.day)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 2, due_at: DateTime.now.in_time_zone + 6.day)

      assignment_created = @assignment.created_at
      assignment_due_dates = DueDate.where(parent_id: @response_map.reviewed_object_id)
      round = 2
      color = []
      resp_color = check_submission_state(@response_map, assignment_created, assignment_due_dates, round, color)
      expect(resp_color).to eq(['green'])
    end

    it 'should return purple color if the assignment was submitted within the round' do
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')
      create(:submission_record, assignment_id: @assignment.id, team_id: @reviewee.id, operation: 'Submit Hyperlink', content: 'https://wiki.archlinux.org/', created_at: DateTime.now.in_time_zone - 7.day)
      create(:response, response_map: @response_map)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 1, due_at: DateTime.now.in_time_zone - 5.day)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 2, due_at: DateTime.now.in_time_zone + 6.day)

      assignment_created = @assignment.created_at
      assignment_due_dates = DueDate.where(parent_id: @response_map.reviewed_object_id)
      round = 2
      color = []
      resp_color = check_submission_state(@response_map, assignment_created, assignment_due_dates, round, color)
      expect(resp_color).to eq(['purple'])
    end
  end

  describe 'get_awarded_review_score' do
    before(:each) do
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')

      @assignment = create(:assignment, created_at: DateTime.now.in_time_zone - 13.day)

      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 1)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 2)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 3)

      student = create(:student)
      @reviewee = create(:assignment_team, assignment: @assignment)
      @reviewer = create(:participant, assignment: @assignment, user: student)

      create(:team_user, user: student, team: @reviewee)

      @review_scores = {@reviewer.id => {1 => {@reviewee.id => 10}, 2 => {@reviewee.id => 20}, 3 => {@reviewee.id => 30}}}

      get_awarded_review_score(@reviewer.id, @reviewee.id)
    end


    it 'should return the review score given by a reviewer for round 1 for the defined team' do
      expect(@score_awarded_round_1).to eq "10%"
    end

    it 'should return the review score given by a reviewer for round 2 for the defined team' do
      expect(@score_awarded_round_2).to eq "20%"
    end

    it 'should return the review score given by a reviewer for round 3 for the defined team' do
      expect(@score_awarded_round_3).to eq "30%"
    end
  end

  describe 'link_updated_since_last?' do

    before(:each) do
      
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')

      assignment = create(:assignment, name: 'assignment', created_at: DateTime.now.in_time_zone - 13.day)
      reviewer = create(:participant, review_grade: nil)
      reviewee = create(:assignment_team, assignment: assignment)
      response_map = create(:review_response_map, reviewer: reviewer, reviewee: reviewee)

      @round = 2
      create(:assignment_due_date, round: 1, due_at: DateTime.now.in_time_zone + 5.day)
      create(:assignment_due_date, round: 2, due_at: DateTime.now.in_time_zone + 10.day)
      @due_dates = DueDate.where(parent_id: response_map.reviewed_object_id)
      
    end

    it 'should return false if submission link was not updated between the last round and the current one' do
      link_updated_at = DateTime.now.in_time_zone + 1.day

      result = link_updated_since_last?(@round, @due_dates, link_updated_at)
      expect(result).to eq(false)
    end

    it 'should return true if submission link was updated between the last round and the current one' do
      link_updated_at = DateTime.now.in_time_zone + 7.day

      result = link_updated_since_last?(@round, @due_dates, link_updated_at)
      expect(result).to eq(true)
    end

  end

  ## rspec test for obtain_team_color method

  describe 'obtain_team_color' do

    before(:each) do

      @assignment = create(:assignment, created_at: DateTime.now.in_time_zone - 13.day)
      @reviewer = create(:participant, review_grade: nil)
      @reviewee = create(:assignment_team, assignment: @assignment)
      @response_map = create(:review_response_map, reviewer: @reviewer, reviewee: @reviewee)
    end

    it 'should return purple if previous round was not submitted but submitted in current round' do
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')

      create(:submission_record, assignment_id: @assignment.id, team_id: @reviewee.id, operation: 'Submit Hyperlink', content: 'https://wiki.archlinux.org/', created_at: DateTime.now.in_time_zone + 5.day)
      create(:response, response_map: @response_map)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 1, due_at: DateTime.now.in_time_zone - 5.day)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 2, due_at: DateTime.now.in_time_zone + 6.day)

      assignment_created = @assignment.created_at
      assignment_due_dates = DueDate.where(parent_id: @response_map.reviewed_object_id)
      
      
      last_round_color = obtain_team_colour(@response_map, assignment_created, assignment_due_dates)
      expect(last_round_color).to eq('purple')
    end


    it 'should return color for 4th round in a 4-round assignment' do
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')

      create(:submission_record, assignment_id: @assignment.id, team_id: @reviewee.id, operation: 'Submit Hyperlink', content: 'https://wiki.archlinux.org/', created_at: DateTime.now.in_time_zone + 1.day)
      create(:submission_record, assignment_id: @assignment.id, team_id: @reviewee.id, operation: 'Submit Hyperlink', content: 'https://wiki.archlinux.org/', created_at: DateTime.now.in_time_zone + 3.day)
      create(:submission_record, assignment_id: @assignment.id, team_id: @reviewee.id, operation: 'Submit Hyperlink', content: 'https://wiki.archlinux.org/', created_at: DateTime.now.in_time_zone + 5.day)
      create(:submission_record, assignment_id: @assignment.id, team_id: @reviewee.id, operation: 'Submit Hyperlink', content: 'https://wiki.archlinux.org/', created_at: DateTime.now.in_time_zone + 7.day)

      create(:response, response_map: @response_map)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 1, due_at: DateTime.now.in_time_zone + 2.day)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 2, due_at: DateTime.now.in_time_zone + 4.day)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 2, due_at: DateTime.now.in_time_zone + 6.day)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 2, due_at: DateTime.now.in_time_zone + 8.day)

      assignment_created = @assignment.created_at
      assignment_due_dates = DueDate.where(parent_id: @response_map.reviewed_object_id)
	
      last_round_color = obtain_team_colour(@response_map, assignment_created, assignment_due_dates)
      expect(last_round_color).to eq('purple')
	    
    end

    it 'should return green if there was no assignment submission in any round' do
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')

      
      create(:response, response_map: @response_map)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 1, due_at: DateTime.now.in_time_zone - 5.day)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 2, due_at: DateTime.now.in_time_zone + 6.day)

      assignment_created = @assignment.created_at
      assignment_due_dates = DueDate.where(parent_id: @response_map.reviewed_object_id)
      
      last_round_color = obtain_team_colour(@response_map, assignment_created, assignment_due_dates)
      expect(last_round_color).to eq('green')
    end


    it 'should return color of 3rd round in a 3-round submitted assignment' do
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')

      create(:submission_record, assignment_id: @assignment.id, team_id: @reviewee.id, operation: 'Submit Hyperlink', content: 'https://wiki.archlinux.org/', created_at: DateTime.now.in_time_zone - 7.day)
      create(:submission_record, assignment_id: @assignment.id, team_id: @reviewee.id, operation: 'Submit Hyperlink', content: 'https://wiki.archlinux.org/', created_at: DateTime.now.in_time_zone + 4.day)
      create(:response, response_map: @response_map)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 1, due_at: DateTime.now.in_time_zone - 5.day)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 2, due_at: DateTime.now.in_time_zone + 6.day)

      assignment_created = @assignment.created_at
      assignment_due_dates = DueDate.where(parent_id: @response_map.reviewed_object_id)

      last_round_color = obtain_team_colour(@response_map, assignment_created, assignment_due_dates)
      expect(last_round_color).to eq('purple')

    end

  end




end
