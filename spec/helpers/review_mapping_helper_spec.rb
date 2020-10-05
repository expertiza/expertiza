require 'spec_helper'
require 'rails_helper'

describe ReviewMappingHelper, type: :helper do

  let(:response) {build(:response, map_id: 2, visibility: 'public')}
  let(:review_response_map) {build(:review_response_map, id: 2)}

  describe '#visibility_public?' do
    it 'should return true if visibility is public or published' do
      allow(Response).to receive(:where).with(map_id: 2, visibility: ['public', 'published']).and_return(response)
      allow(response).to receive(:exists?).and_return(true)
      expect(helper.visibility_public?(review_response_map)).to be true
    end
  end

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

      student = create(:student)
      @reviewee = create(:assignment_team, assignment: @assignment)
      create(:team_user, user: student, team: @reviewee)
      @reviewer = create(:participant, assignment: @assignment, user: student)

      @response_map_1 = create(:review_response_map, reviewer: @reviewer)
      @response_map_2 = create(:review_response_map, reviewer: @reviewer)
      @response_map_3 = create(:review_response_map, reviewer: @reviewer)

      @review_response_map_list = []
      @review_response_map_list << @response_map_1.id
      @review_response_map_list << @response_map_2.id
      @review_response_map_list << @response_map_3.id

      @response_list = []
      @feedback_response_map_list = []
      @all_review_response_ids = []

      @response_1 = create(:response, response_map: @response_map_1, round: 1)
      @response_list << @response_1
      @feedback_response_map_list << FeedbackResponseMap.create(reviewed_object_id: @response_1.id, reviewer_id: @reviewer.id)
      @all_review_response_ids << @response_1.id

      @response_2 = create(:response, response_map: @response_map_2, round: 2)
      @response_list << @response_2
      @feedback_response_map_list << FeedbackResponseMap.create(reviewed_object_id: @response_2.id, reviewer_id: @reviewer.id)
      @all_review_response_ids << @response_2.id
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
      get_each_review_and_feedback_response_map(@reviewer)

      # rspan means the all peer reviews one student received, including unfinished one
      # retrieved from method call in review_mapping_helper.rb file
      expect(@rspan_round_three).to eq 0
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
end
