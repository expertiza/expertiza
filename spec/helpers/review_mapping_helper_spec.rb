require 'spec_helper'

describe ReviewMappingHelper, type: :helper do

  let(:response) { build(:response, map_id: 2, visibility: 'public') }
  let(:review_response_map) { build(:review_response_map, id: 2) }
  
#  describe '#visibility_public?' do
#
#    it 'should return true if visibility is public or published' do
#      allow(Response).to receive(:where).with(map_id: 2, visibility: ['public','published']).and_return(response)
#      allow(response).to receive(:exists?).and_return(true)
#      expect(helper.visibility_public?(review_response_map)).to be true
#    end
#  end

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
