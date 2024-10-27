require 'spec_helper'
require 'rails_helper'

describe ReviewMappingHelper, type: :helper do
  let(:team) { build(:assignment_team, id: 1) }
  let(:test_item) { build(:answer, id: 1, comments: 'https://wiki.archlinux.org/') }
  let(:test_response) { build(:response, id: 1) }
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

      color = get_team_color(response_map_dne)
      expect(color).to eq('red')
    end

    it 'color should be blue if the a review was submitted for each round' do
      # deadline_right inspired from bookmark_review_
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')

      # make a team for the assignment
      create(:assignment_team, assignment: @assignment)

      response_map_with_reviewee = create(:review_response_map, reviewer: @reviewer, reviewee: @reviewee)

      create(:submission_record, assignment_id: @assignment.id, team_id: @reviewee.id, operation: 'Submit Hyperlink', content: 'random link')

      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 1)

      create(:response, response_map: response_map_with_reviewee)

      color = get_team_color(response_map_with_reviewee)
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

      color = get_team_color(@response_map)
      expect(color).not_to eq('blue')
    end

    it 'color should be brown if the review and review_grade exist' do
      review_grade = create(:review_grade)
      reviewer_with_grade = create(:participant, review_grade: review_grade)
      response_map_with_grade_reviewer = create(:review_response_map, reviewer: reviewer_with_grade)
      create(:response, response_map: response_map_with_grade_reviewer)

      color = get_team_color(response_map_with_grade_reviewer)
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

      color = get_team_color(@response_map)
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

      color = get_team_color(response_map_with_reviewee)
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

      color = get_team_color(response_map_with_reviewee)
      expect(color).to eq('purple')
    end

    xit 'color should be purple if submission link has been updated since due date for a specified round' do
      # deadline_right inspired from bookmark_review_spec
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')

      response_map_with_reviewee = create(:review_response_map, reviewer: @reviewer, reviewee: @reviewee_with_assignment)

      create(:submission_record, assignment_id: @assignment.id, team_id: @reviewee_with_assignment.id, operation: 'Submit Hyperlink', content: 'https://wiki.archlinux.org/', created_at: DateTime.now.in_time_zone - 7.day)

      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 1, due_at: DateTime.now.in_time_zone - 5.day)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 2, due_at: DateTime.now.in_time_zone + 6.day)

      create(:response, response_map: response_map_with_reviewee)

      color = get_team_color(response_map_with_reviewee)
      expect(color).to eq('purple')
    end
  end

  describe 'response_for_each_round?' do
    before(:each) do
      @assignment = create(:assignment, created_at: DateTime.now.in_time_zone - 13.day)
      @reviewer = create(:participant, review_grade: nil)
      @reviewee = create(:assignment_team)
      @reviewee_with_assignment = create(:assignment_team, assignment: @assignment)
      @response_map = create(:review_response_map, reviewer: @reviewer)
    end

    # one round, no response
    it 'should return false if response was not submitted in every round' do
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 1)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 2)

      create(:response, response_map: @response_map)
      check_response = response_for_each_round?(@response_map)
      expect(check_response).to eq(false)
    end

    # one round, one response
    it 'should return true if there is one response with one round' do
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')

      # make a team for the assignment
      create(:assignment_team, assignment: @assignment)

      response_map_with_reviewee = create(:review_response_map, reviewer: @reviewer, reviewee: @reviewee)
      create(:submission_record, assignment_id: @assignment.id, team_id: @reviewee.id, operation: 'Submit Hyperlink', content: 'random link', created_at: DateTime.now.in_time_zone - 7.day)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 1, due_at: DateTime.now.in_time_zone - 5.day)
      create(:response, response_map: response_map_with_reviewee)

      check_response = response_for_each_round?(response_map_with_reviewee)
      expect(check_response).to eq(true)
    end

    # two round,two response
    it 'should return true if there were both response' do
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')

      # make a team for the assignment
      create(:assignment_team, assignment: @assignment)

      response_map_with_reviewee = create(:review_response_map, reviewer: @reviewer, reviewee: @reviewee)
      create(:submission_record, assignment_id: @assignment.id, team_id: @reviewee.id, operation: 'Submit Hyperlink', content: 'random link', created_at: DateTime.now.in_time_zone - 7.day)
      create(:submission_record, assignment_id: @assignment.id, team_id: @reviewee.id, operation: 'Submit Hyperlink', content: 'random link', created_at: DateTime.now.in_time_zone - 3.day)

      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 1, due_at: DateTime.now.in_time_zone - 5.day)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 2, due_at: DateTime.now.in_time_zone - 2.day)
      create(:response, response_map: response_map_with_reviewee, round: 1)
      create(:response, response_map: response_map_with_reviewee, round: 2)

      check_response = response_for_each_round?(response_map_with_reviewee)
      expect(check_response).to eq(true)
    end

    # two round, only have first response
    it 'should return false if only have first response' do
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')

      # make a team for the assignment
      create(:assignment_team, assignment: @assignment)

      response_map_with_reviewee = create(:review_response_map, reviewer: @reviewer, reviewee: @reviewee)
      create(:submission_record, assignment_id: @assignment.id, team_id: @reviewee.id, operation: 'Submit Hyperlink', content: 'random link', created_at: DateTime.now.in_time_zone - 2.day)
      create(:submission_record, assignment_id: @assignment.id, team_id: @reviewee.id, operation: 'Submit Hyperlink', content: 'random link', created_at: DateTime.now.in_time_zone - 3.day)

      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 1, due_at: DateTime.now.in_time_zone - 5.day)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 2, due_at: DateTime.now.in_time_zone + 6.day)
      create(:response, response_map: response_map_with_reviewee, round: 1)

      check_response = response_for_each_round?(response_map_with_reviewee)
      expect(check_response).to eq(false)
    end

    # two round,only have second response
    it 'should return false if only have second response' do
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')

      # make a team for the assignment
      create(:assignment_team, assignment: @assignment)

      response_map_with_reviewee = create(:review_response_map, reviewer: @reviewer, reviewee: @reviewee)
      create(:submission_record, assignment_id: @assignment.id, team_id: @reviewee.id, operation: 'Submit Hyperlink', content: 'random link', created_at: DateTime.now.in_time_zone - 7.day)
      create(:submission_record, assignment_id: @assignment.id, team_id: @reviewee.id, operation: 'Submit Hyperlink', content: 'random link', created_at: DateTime.now.in_time_zone - 1.day)

      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 1, due_at: DateTime.now.in_time_zone - 5.day)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 2, due_at: DateTime.now.in_time_zone - 2.day)
      create(:response, response_map: response_map_with_reviewee, round: 2)

      check_response = response_for_each_round?(response_map_with_reviewee)
      expect(check_response).to eq(false)
    end
  end

  # round, response_map, assignment_created, assignment_due_dates
  describe 'submitted_within_round?' do
    before(:each) do
      @assignment = create(:assignment, name: 'assignment', created_at: DateTime.now.in_time_zone - 13.day)
      @reviewer = create(:participant, review_grade: nil)
      @reviewee = create(:assignment_team, assignment: @assignment)
      @response_map = create(:review_response_map, reviewer: @reviewer, reviewee: @reviewee)

      # create due dates for assignment
      @round = 2
    end

    # for two round, both of the submissions are on time
    it 'should return true if works were submitted within 2 round' do
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')
      create(:submission_record, assignment_id: @assignment.id, team_id: @reviewee.id, operation: 'Submit Hyperlink', content: 'https://wiki.archlinux.org/', created_at: DateTime.now.in_time_zone - 7.day)
      create(:submission_record, assignment_id: @assignment.id, team_id: @reviewee.id, operation: 'Submit Hyperlink', content: 'https://wiki.archlinux.org/', created_at: DateTime.now.in_time_zone - 1.day)
      create(:response, response_map: @response_map)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 1, due_at: DateTime.now.in_time_zone - 5.day)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 2, due_at: DateTime.now.in_time_zone + 6.day)

      assignment_created = @assignment.created_at
      assignment_due_dates = DueDate.where(parent_id: @response_map.reviewed_object_id)

      check_submitetd = submitted_within_round?(@round, @response_map, assignment_created, assignment_due_dates)
      expect(check_submitetd).to eq(true)
    end

    # for two round, both of the submissions are late
    it 'should return false if both works was submitted late' do
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')
      create(:submission_record, assignment_id: @assignment.id, team_id: @reviewee.id, operation: 'Submit Hyperlink', content: 'https://wiki.archlinux.org/', created_at: DateTime.now.in_time_zone - 4.day)
      create(:submission_record, assignment_id: @assignment.id, team_id: @reviewee.id, operation: 'Submit Hyperlink', content: 'https://wiki.archlinux.org/', created_at: DateTime.now.in_time_zone - 3.day)
      create(:response, response_map: @response_map)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 1, due_at: DateTime.now.in_time_zone - 10.day)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 2, due_at: DateTime.now.in_time_zone - 5.day)

      assignment_created = @assignment.created_at
      assignment_due_dates = DueDate.where(parent_id: @response_map.reviewed_object_id)

      check_submitetd = submitted_within_round?(@round, @response_map, assignment_created, assignment_due_dates)
      expect(check_submitetd).to eq(false)
    end

    # for two round, only the second submission is on time
    # We spent some time to figure out the logic in this function,
    # but now we believe whether an assignment is late depends on the last due date.
    # So, assignment will view as on time if user submitted before the last deadline.
    it 'should return true if first work was submitted late' do
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')
      create(:submission_record, assignment_id: @assignment.id, team_id: @reviewee.id, operation: 'Submit Hyperlink', content: 'https://wiki.archlinux.org/', created_at: DateTime.now.in_time_zone - 7.day)
      create(:submission_record, assignment_id: @assignment.id, team_id: @reviewee.id, operation: 'Submit Hyperlink', content: 'https://wiki.archlinux.org/', created_at: DateTime.now.in_time_zone - 6.day)
      create(:response, response_map: @response_map)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 1, due_at: DateTime.now.in_time_zone - 10.day)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 2, due_at: DateTime.now.in_time_zone - 5.day)

      assignment_created = @assignment.created_at
      assignment_due_dates = DueDate.where(parent_id: @response_map.reviewed_object_id)

      check_submitetd = submitted_within_round?(@round, @response_map, assignment_created, assignment_due_dates)
      expect(check_submitetd).to eq(true)
    end

    # for two round, only the first submission is on time
    # If you miss the last submission, than it will return false
    it 'should return false if second work was submitted late' do
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')
      create(:submission_record, assignment_id: @assignment.id, team_id: @reviewee.id, operation: 'Submit Hyperlink', content: 'https://wiki.archlinux.org/', created_at: DateTime.now.in_time_zone - 11.day)
      create(:submission_record, assignment_id: @assignment.id, team_id: @reviewee.id, operation: 'Submit Hyperlink', content: 'https://wiki.archlinux.org/', created_at: DateTime.now.in_time_zone - 2.day)
      create(:response, response_map: @response_map)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 1, due_at: DateTime.now.in_time_zone - 10.day)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 2, due_at: DateTime.now.in_time_zone - 5.day)

      assignment_created = @assignment.created_at
      assignment_due_dates = DueDate.where(parent_id: @response_map.reviewed_object_id)

      check_submitetd = submitted_within_round?(@round, @response_map, assignment_created, assignment_due_dates)
      expect(check_submitetd).to eq(false)
    end
  end

  # round, response_map, assignment_created, assignment_due_dates
  describe 'submitted_hyperlink' do
    before(:each) do
      @assignment = create(:assignment, name: 'assignment', created_at: DateTime.now.in_time_zone - 13.day)
      @reviewer = create(:participant, review_grade: nil)
      @reviewee = create(:assignment_team, assignment: @assignment)
      @response_map = create(:review_response_map, reviewer: @reviewer, reviewee: @reviewee)

      # create rounds for assignment
      @round = 2
    end

    # If there were several submissions on time, than it will return the latest one
    it 'should return https://wiki.archlinux.org/123 if works was submitted on time' do
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')
      create(:submission_record, assignment_id: @assignment.id, team_id: @reviewee.id, operation: 'Submit Hyperlink', content: 'https://wiki.archlinux.org/', created_at: DateTime.now.in_time_zone - 12.day)
      create(:submission_record, assignment_id: @assignment.id, team_id: @reviewee.id, operation: 'Submit Hyperlink', content: 'https://wiki.archlinux.org/123', created_at: DateTime.now.in_time_zone - 7.day)
      create(:response, response_map: @response_map)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 1, due_at: DateTime.now.in_time_zone - 10.day)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 2, due_at: DateTime.now.in_time_zone - 5.day)

      assignment_created = @assignment.created_at
      assignment_due_dates = DueDate.where(parent_id: @response_map.reviewed_object_id)

      hyper_link = submitted_hyperlink(@round, @response_map, assignment_created, assignment_due_dates)
      expect(hyper_link).to eq('https://wiki.archlinux.org/123')
    end

    # If there were some submissions miss the due date, than ignore them
    it 'should return https://wiki.archlinux.org/123 if only a work was submitted on time' do
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')
      create(:submission_record, assignment_id: @assignment.id, team_id: @reviewee.id, operation: 'Submit Hyperlink', content: 'https://wiki.archlinux.org/', created_at: DateTime.now.in_time_zone - 8.day)
      create(:submission_record, assignment_id: @assignment.id, team_id: @reviewee.id, operation: 'Submit Hyperlink', content: 'https://wiki.archlinux.org/123', created_at: DateTime.now.in_time_zone - 6.day)
      create(:response, response_map: @response_map)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 1, due_at: DateTime.now.in_time_zone - 10.day)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 2, due_at: DateTime.now.in_time_zone - 5.day)

      assignment_created = @assignment.created_at
      assignment_due_dates = DueDate.where(parent_id: @response_map.reviewed_object_id)

      hyper_link = submitted_hyperlink(@round, @response_map, assignment_created, assignment_due_dates)
      expect(hyper_link).to eq('https://wiki.archlinux.org/123')
    end

    # If there were some submissions miss the due date, than ignore them
    it 'should return https://wiki.archlinux.org/ if only a work was submitted on time' do
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')
      create(:submission_record, assignment_id: @assignment.id, team_id: @reviewee.id, operation: 'Submit Hyperlink', content: 'https://wiki.archlinux.org/', created_at: DateTime.now.in_time_zone - 12.day)
      create(:submission_record, assignment_id: @assignment.id, team_id: @reviewee.id, operation: 'Submit Hyperlink', content: 'https://wiki.archlinux.org/123', created_at: DateTime.now.in_time_zone - 4.day)
      create(:response, response_map: @response_map)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 1, due_at: DateTime.now.in_time_zone - 10.day)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 2, due_at: DateTime.now.in_time_zone - 5.day)

      assignment_created = @assignment.created_at
      assignment_due_dates = DueDate.where(parent_id: @response_map.reviewed_object_id)

      hyper_link = submitted_hyperlink(@round, @response_map, assignment_created, assignment_due_dates)
      expect(hyper_link).to eq('https://wiki.archlinux.org/')
    end
  end

  # input max_team_size, response, reviewee_id, ip_address
  describe 'get_team_reviewed_link_name' do
    before(:each) do
      @assignment = create(:assignment, created_at: DateTime.now.in_time_zone - 13.day)
      @reviewer = create(:participant, review_grade: nil)

      @reviewee = create(:assignment_team, name: 'Team_1')
      @response_map = create(:review_response_map, reviewer: @reviewer)
    end

    # return the team name if team size not equal 1
    it 'should return (Team_1) if max_team_size = 3' do
      max_team_size = 3
      @response = create(:response, response_map: @response_map)
      ip_address = '0.0.0.0'
      reviewed_team_name = get_team_reviewed_link_name(max_team_size, @response, @reviewee.id, ip_address)
      expect(reviewed_team_name).to eq('(Team_1)')
    end

    # return the team name if team size not equal 1
    it 'should return (Team_1) if max_team_size = 2' do
      max_team_size = 2
      @response = create(:response, response_map: @response_map)
      ip_address = '0.0.0.0'
      reviewed_team_name = get_team_reviewed_link_name(max_team_size, @response, @reviewee.id, ip_address)
      expect(reviewed_team_name).to eq('(Team_1)')
    end

    # return the user name if team size equal 1
    it 'should return (Adam) if max_team_size = 1' do
      max_team_size = 1
      student = create(:student, fullname: 'Adam')
      create(:team_user, user: student, team: @reviewee)

      @response = create(:response, response_map: @response_map)
      ip_address = '0.0.0.0'
      reviewed_team_name = get_team_reviewed_link_name(max_team_size, @response, @reviewee.id, ip_address)
      expect(reviewed_team_name).to eq('(Adam)')
    end

    # return the team name if team size not equal 1
    it 'should return (Team_1) if max_team_size = 0' do
      max_team_size = 0
      @response = create(:response, response_map: @response_map)
      ip_address = '0.0.0.0'
      reviewed_team_name = get_team_reviewed_link_name(max_team_size, @response, @reviewee.id, ip_address)
      expect(reviewed_team_name).to eq('(Team_1)')
    end
  end

  # the function will sort reviewer based on the comment length
  describe 'sort_reviewer_by_review_volume_desc' do
    before(:each) do
      @assignment = create(:assignment, name: 'assignment', created_at: DateTime.now.in_time_zone - 13.day)
      @reviewee = create(:assignment_team, assignment: @assignment)

      @reviewer_1 = create(:participant, review_grade: nil)
      @reviewer_2 = create(:participant, review_grade: nil)
      @reviewer_3 = create(:participant, review_grade: nil)

      @response_map_1 = create(:review_response_map, reviewer: @reviewer_1, reviewee: @reviewee)
      @response_map_2 = create(:review_response_map, reviewer: @reviewer_2, reviewee: @reviewee)
      @response_map_3 = create(:review_response_map, reviewer: @reviewer_3, reviewee: @reviewee)
    end

    it 'the order should be 2-3-1 if the order of comment volume is 2 > 3 > 1' do
      @response_1 = create(:response, response_map: @response_map_1, additional_comment: 'good')
      @response_2 = create(:response, response_map: @response_map_2, additional_comment: 'Good job with clear code')
      @response_3 = create(:response, response_map: @response_map_3, additional_comment: 'goodclear code')

      @reviewers = Array[@reviewer_1, @reviewer_2, @reviewer_3]
      @reviewers_for_test = Array[@reviewer_2, @reviewer_3, @reviewer_1]

      sort_reviewer_by_review_volume_desc
      expect(@reviewers).to eq(@reviewers_for_test)
    end

    it 'the order should be 2-1-3 if the comment volume is 2 > 1 = 3' do
      @response_1 = create(:response, response_map: @response_map_1, additional_comment: 'good job')
      @response_2 = create(:response, response_map: @response_map_2, additional_comment: 'Good job with clear code')
      @response_3 = create(:response, response_map: @response_map_3, additional_comment: 'clear code')

      @reviewers = Array[@reviewer_1, @reviewer_2, @reviewer_3]
      @reviewers_for_test = Array[@reviewer_2, @reviewer_1, @reviewer_3]

      sort_reviewer_by_review_volume_desc
      expect(@reviewers).to eq(@reviewers_for_test)
    end

    it 'the order should be 1-2-3 if the comment volume is 1 = 2 = 3' do
      @response_1 = create(:response, response_map: @response_map_1, additional_comment: 'good job')
      @response_2 = create(:response, response_map: @response_map_2, additional_comment: 'clear code')
      @response_3 = create(:response, response_map: @response_map_3, additional_comment: 'nice bro')

      @reviewers = Array[@reviewer_1, @reviewer_2, @reviewer_3]
      @reviewers_for_test = Array[@reviewer_1, @reviewer_2, @reviewer_3]

      sort_reviewer_by_review_volume_desc
      expect(@reviewers).to eq(@reviewers_for_test)
    end
  end

  # I found the test case by internet, and I think it will fail if the website update in future
  describe 'get_link_updated_at' do
    it 'should return ? by input http://www.example.com' do
      updated_time = get_link_updated_at('http://www.example.com')
      expect(updated_time).to eq('2019-10-17 03:18:26.000000000 -0400')
    end
  end

  # initialize_chart_elements
  # display_volume_metric_chart
  # display_tagging_interval_chart
  # list_review_submissions
  # list_hyperlink_submission
  # get_certain_review_and_feedback_response_map

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

    it 'should return the response_map id associated with round 1' do
      expect(@review_responses_round_one.first.id).to eq(@response_map_1.id)
    end

    it 'should return the response_map id associated with round 2' do
      expect(@review_responses_round_two.first.id).to eq(@response_map_2.id)
    end

    it 'should return the response_map id associated with round 3' do
      expect(@review_responses_round_three.first.id).to eq(@response_map_3.id)
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

    xit 'should return purple color if the assignment was submitted within the round' do
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

      @review_scores = { @reviewer.id => { 1 => { @reviewee.id => 10 }, 2 => { @reviewee.id => 20 }, 3 => { @reviewee.id => 30 } } }

      get_awarded_review_score(@reviewer.id, @reviewee.id)
    end

    it 'should return the review score given by a reviewer for round 1 for the defined team' do
      expect(@score_awarded_round_1).to eq '10%'
    end

    it 'should return the review score given by a reviewer for round 2 for the defined team' do
      expect(@score_awarded_round_2).to eq '20%'
    end

    it 'should return the review score given by a reviewer for round 3 for the defined team' do
      expect(@score_awarded_round_3).to eq '30%'
    end
  end

  # rspec test for link_updated_since_last? method
  describe 'link_updated_since_last?' do
    before(:each) do
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')

      # create assignment and respective reviewer, reviewee instance variables
      assignment = create(:assignment, name: 'assignment', created_at: DateTime.now.in_time_zone - 13.day)
      reviewer = create(:participant, review_grade: nil)
      reviewee = create(:assignment_team, assignment: assignment)
      response_map = create(:review_response_map, reviewer: reviewer, reviewee: reviewee)

      # create due dates for assignment
      @round = 2
      create(:assignment_due_date, round: 1, due_at: DateTime.now.in_time_zone + 5.day)
      create(:assignment_due_date, round: 2, due_at: DateTime.now.in_time_zone + 10.day)
      @due_dates = DueDate.where(parent_id: response_map.reviewed_object_id)
    end

    # This test case asserts that false is returned when submission link is not updated from the last round
    it 'should return false if submission link was not updated between the last round and the current one' do
      link_updated_at = DateTime.now.in_time_zone + 1.day

      result = link_updated_since_last?(@round, @due_dates, link_updated_at)
      expect(result).to eq(false)
    end

    # This test case asserts that true is returned when submission link is updated from last round
    it 'should return true if submission link was updated between the last round and the current one' do
      link_updated_at = DateTime.now.in_time_zone + 7.day

      result = link_updated_since_last?(@round, @due_dates, link_updated_at)
      expect(result).to eq(true)
    end
  end

  # rspec test for obtain_team_color method
  describe 'obtain_team_color' do
    before(:each) do
      # create assignment and respective reviewer, reviewee instance variables
      @assignment = create(:assignment, created_at: DateTime.now.in_time_zone - 13.day)
      @reviewer = create(:participant, review_grade: nil)
      @reviewee = create(:assignment_team, assignment: @assignment)
      @response_map = create(:review_response_map, reviewer: @reviewer, reviewee: @reviewee)
    end

    # Following test cases to assert whether the right color is returned by obtain_team_color for the given combination of pre-conditions

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

      last_round_color = obtain_team_color(@response_map, assignment_created, assignment_due_dates)
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

      last_round_color = obtain_team_color(@response_map, assignment_created, assignment_due_dates)
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

      last_round_color = obtain_team_color(@response_map, assignment_created, assignment_due_dates)
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

      last_round_color = obtain_team_color(@response_map, assignment_created, assignment_due_dates)
      expect(last_round_color).to eq('purple')
    end
  end

  # rspec test for review_metrics method
  describe 'review_metrics' do
    before(:each) do
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')

      # create assignment(with due dates for each round) and respective reviewer, reviewee instance variables
      @assignment = create(:assignment, created_at: DateTime.now.in_time_zone - 13.day)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 1)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 2)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 3)

      student = create(:student)
      @reviewee = create(:assignment_team, assignment: @assignment)
      @reviewer = create(:participant, assignment: @assignment, user: student)

      # Populate @avg_and_ranges instance variable required for lookup to extract the metrics for the given round in review_metrics method.
      # Each round in avg_and_ranges must have a symbol and a string for the metric as indicated by corresponding source code
      # Here, key is the round number (1, 2, 3 ., etc) and the value is the metrics (min, max, avg) for the given round number.
      @avg_and_ranges = {
        @reviewee.id =>
            {
              1 => {
                :min => 2,
                'min' => 2,
                :max => 4,
                'max' => 4,
                :avg => 3,
                'avg' => 3
              },
              2 => {
                'min' => 5,
                :min => 5,
                'max' => 7,
                :max => 7,
                'avg' => 6,
                :avg => 6
              },
              3 => {
                'min' => 8,
                :min => 8,
                'max' => 10,
                :max => 10,
                'avg' => 9,
                :avg => 9
              }
            }
      }

      create(:team_user, user: student, team: @reviewee)
    end

    # assert the value for metrics in round 1 for given team_id
    it 'should return minimum maximum and average score for round 1' do
      @round = 1
      review_metrics(@round, @reviewee.id)
      expect(@min).to eq '2%'
      expect(@max).to eq '4%'
      expect(@avg).to eq '3%'
    end

    # assert the value for metrics in round 2 for given team_id
    it 'should return the minimum, maximum and average score for round 2' do
      @round = 2
      review_metrics(@round, @reviewee.id)
      expect(@min).to eq '5%'
      expect(@max).to eq '7%'
      expect(@avg).to eq '6%'
    end

    # assert the value metrics in round 3 for given team_id
    it 'should return the minimum, maximum and average score for round 3' do
      @round = 3
      review_metrics(@round, @reviewee.id)
      expect(@min).to eq '8%'
      expect(@max).to eq '10%'
      expect(@avg).to eq '9%'
    end
  end
  describe 'test calculate_key_chart_information' do
    it 'should return new Hash if intervals are not empty' do
      intervals = [1.00, 2.00, 3.00, 4.00, 5.00, 6.00]
      result = helper.calculate_key_chart_information(intervals)
      expect(result).to be_a_kind_of(Hash)
      expect(result[:mean]).to eq(3.50)
      expect(result[:min]).to eq(1.00)
      expect(result[:max]).to eq(6.00)
      expect(result[:variance]).to eq(2.92)
      expect(result[:stand_dev]).to eq(1.71)
    end
  end

  describe 'test calculate_key_chart_information' do
    it 'should return nil if intervals are empty' do
      intervals = []
      result = helper.calculate_key_chart_information(intervals)
      expect(result).to be_nil
    end
  end

  describe 'test get_css_style_for_calibration_report' do
    it 'should return correct css class' do
      css_class_0 = helper.get_css_style_for_calibration_report(0)
      css_class_1 = helper.get_css_style_for_calibration_report(-1)
      css_class_6 = helper.get_css_style_for_calibration_report(6)
      expect(css_class_0). to eq('c5')
      expect(css_class_1). to eq('c4')
      expect(css_class_6). to eq('c1')
    end
  end

  describe 'test list_review_submissions' do
    before(:each) do
      @assignment1 = create(:assignment, name: 'name1')
      @questionnaire = create(:questionnaire)
      @question = create(:question, questionnaire_id: @questionnaire.id)
      @user = create(:student, username: 'name', fullname: 'name')
      @participant = create(:participant, user_id: @user.id, parent_id: @assignment1.id)
      @response_map = create(:review_response_map, reviewer: @participant, assignment: @assignment1)
      @response = create(:response, response_map: @response_map, created_at: '2019-11-01 23:30:00')
      @answer = create(:answer, response_id: @response.id, question_id: @question.id, comments: 'comment')
      @team = create(:assignment_team)
    end
    it 'should return an empty string when the file does not exist' do
      result = helper.list_review_submissions(@participant.id, @team.id, @response_map.id)
      expect(result).to eq('')
    end
  end

  describe 'test list_review_submissions' do
    before(:each) do
      @assignment1 = create(:assignment, name: 'name1')
      @questionnaire = create(:questionnaire)
      @question = create(:question, questionnaire_id: @questionnaire.id)
      @user = create(:student, username: 'name', fullname: 'name')
      @participant = create(:participant, user_id: @user.id, parent_id: @assignment1.id)
      @response_map = create(:review_response_map, reviewer: @participant, assignment: @assignment1)
      @response = create(:response, response_map: @response_map, created_at: '2019-11-01 23:30:00')
      @answer = create(:answer, response_id: @response.id, question_id: @question.id, comments: 'comment')
      @team = create(:assignment_team)
      allow(AssignmentTeam).to receive(:find).with(@team.id).and_return(team)
      allow(team).to receive(:submitted_files).with(any_args).and_return(['./.rspec'])
    end
    it 'should return correct html a tag' do
      result = helper.list_review_submissions(@participant.id, @team.id, @response_map.id)
      expect(result).to start_with('<a href')
    end
  end

  describe 'test list_hyperlink_submission' do
    before(:each) do
      @assignment1 = create(:assignment, name: 'name1')
      @questionnaire = create(:questionnaire)
      @question = create(:question, questionnaire_id: @questionnaire.id)
      @user = create(:student, username: 'name', fullname: 'name')
      @participant = create(:participant, user_id: @user.id, parent_id: @assignment1.id)
      @response_map = create(:review_response_map, reviewer: @participant, assignment: @assignment1)
      @id = @assignment1.id
    end
    it 'should return an empty string when comment does not exist' do
      result = helper.list_hyperlink_submission(@response_map.id, @question.id)
      expect(result).to eq('')
    end
  end

  describe 'test list_hyperlink_submission' do
    before(:each) do
      @assignment1 = create(:assignment, name: 'name1')
      @questionnaire = create(:questionnaire)
      @question = create(:question, questionnaire_id: @questionnaire.id)
      @user = create(:student, username: 'name', fullname: 'name')
      @participant = create(:participant, user_id: @user.id, parent_id: @assignment1.id)
      @response_map = create(:review_response_map, reviewer: @participant, assignment: @assignment1)
      @id = @assignment1.id
      allow(Response).to receive(:where).with(any_args).and_return([test_response])
      allow(Answer).to receive(:where).with(any_args).and_return([test_item])
    end
    it 'should return correct html a tag' do
      result = helper.list_hyperlink_submission(@response_map.id, @question.id)
      expect(result).to start_with('<a target="_blank"')
    end
  end
end
