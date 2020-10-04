require 'spec_helper'

describe ReviewMappingHelper, type: :helper do

  let(:response) { build(:response, map_id: 2, visibility: 'public') }
  let(:review_response_map) { build(:review_response_map, id: 2) }

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
      @response_map = create(:review_response_map, reviewer: @reviewer)
    end

    it 'color should be red if response_map does not exist' do
      response_map_dne = create(:does_not_exist)

      color = get_team_colour(response_map_dne)
      expect(color).to be == 'red'
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
      expect(color).to be 'blue'
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
      expect(color).not_to be 'blue'
    end

    it 'color should be brown if the review and review_grade exist' do
      review_grade = create(:review_grade)
      reviewer_with_grade = create(:participant, review_grade: review_grade)
      response_map_with_grade_reviewer = create(:review_response_map, reviewer: reviewer_with_grade)
      create(:response, response_map: response_map_with_grade_reviewer)

      color = get_team_colour(response_map_with_grade_reviewer)
      expect(color).to be 'brown'
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
      expect(color).to be 'green'
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
      expect(color).to be 'green'
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
      expect(color).to be 'purple'
    end

    it 'color should be purple if submission link has been updated since due date for a specified round' do
      # deadline_right inspired from bookmark_review_spec
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')

      # make a team for the assignment
      create(:assignment_team, assignment: @assignment)

      response_map_with_reviewee = create(:review_response_map, reviewer: @reviewer, reviewee: @reviewee)

      create(:submission_record, assignment_id: @assignment.id, team_id: @reviewee.id, operation: 'Submit Hyperlink', content: 'https://en.wikipedia.org/wiki/Ruby_(programming_language)', created_at: DateTime.now.in_time_zone - 7.day)

      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 1, due_at: DateTime.now.in_time_zone - 5.day)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 2, due_at: DateTime.now.in_time_zone + 6.day)

      create(:response, response_map: response_map_with_reviewee)

      color = get_team_colour(response_map_with_reviewee)
      expect(color).to be 'purple'
    end

  end
end
