# frozen_string_literal: true

require 'support/shared_contexts'

describe DueDateHelper do
  def set_due_date(duedate, deadline, assign_id, max_round)
    ActiveRecord::Base.transaction do
      submit_duedate = DueDate.new(duedate)
      submit_duedate.deadline_type_id = deadline
      submit_duedate.parent_id = assign_id
      submit_duedate.round = max_round
      submit_duedate.save
    end
  end

  include_context 'with_deadline_setup'

  it 'sort duedate records' do
    sorted_due_dates = @due_dates
    expect(sorted_due_dates.each_cons(2).all? { |m1, m2| (m1.due_at <=> m2.due_at) != 1 }).to eql false

    sorted_due_dates = DueDateHelper.deadline_sort(@due_dates)
    expect(sorted_due_dates.each_cons(2).all? { |m1, m2| (m1.due_at <=> m2.due_at) != 1 }).to eql true
  end

  describe '#calculate_assignment_round' do
    it 'return 0 when no response map' do
      response = ReviewResponseMap.create
      response.type = 'ResponseMap'
      response.save
      expect(DueDateHelper.calculate_assignment_round(1, response)).to eql 0
    end

    it 'return round 1 for single round' do
      response = ReviewResponseMap.create
      expect(DueDateHelper.calculate_assignment_round(@assignment_due_date.parent_id, response)).to eql 1
    end
  end

  it 'copy due dates to new assignment' do
    new_assignment_id = build(:assignment, id: 999).id
    old_assignment_id = @assignment_due_date.assignment.id
    DueDateHelper.copy(old_assignment_id, new_assignment_id)
    expect(DueDate.where(parent_id: new_assignment_id).count).to eql DueDate.where(parent_id: old_assignment_id).count
  end

  it 'create new duedate record with values' do
    set_due_date({ id: 999 }, @assignment_due_date.deadline_type_id,
                 @assignment_due_date.parent_id, @assignment_due_date.round)
    new_due_date = DueDate.find_by(id: 999)
    expect(new_due_date).to be_valid
    expect(new_due_date.deadline_type_id).to eql @assignment_due_date.deadline_type_id
    expect(new_due_date.parent_id).to eql @assignment_due_date.parent_id
    expect(new_due_date.round).to eql @assignment_due_date.round
  end

  describe '#get_next_due_date' do
    it 'no subsequent due date' do
      expect(DueDateHelper.get_next_due_date(@assignment_due_date.parent_id)).to be nil
    end

    it 'nil value throws exception' do
      expect { DueDateHelper.get_next_due_date(nil) }.to raise_exception(ActiveRecord::RecordNotFound)
    end

    it 'get next assignment due date' do
      due_date = create(:assignment_due_date,
                        deadline_type: @deadline_type,
                        submission_allowed_id: @deadline_right.id,
                        review_allowed_id: @deadline_right.id,
                        review_of_review_allowed_id: @deadline_right.id,
                        due_at: Time.zone.now + 5000)
      expect(DueDateHelper.get_next_due_date(due_date.parent_id)).to be_valid
    end

    it 'get next due date from topic for staggered deadline' do
      assignment_id = create(:assignment, staggered_deadline: true, name: 'TestAssignment1',
                                          directory_path: 'TestAssignment1').id
      due_date = create(:topic_due_date,
                        deadline_type: @deadline_type,
                        submission_allowed_id: @deadline_right.id,
                        review_allowed_id: @deadline_right.id,
                        review_of_review_allowed_id: @deadline_right.id,
                        due_at: Time.zone.now + 5000,
                        parent_id: assignment_id)
      expect(DueDateHelper.get_next_due_date(assignment_id, due_date.parent_id)).to be_valid
    end

    it 'next due date does not exist for staggered deadline' do
      assignment_id = create(:assignment, staggered_deadline: true, name: 'TestAssignment2',
                                          directory_path: 'TestAssignment2').id
      expect(DueDateHelper.get_next_due_date(assignment_id)).to be nil
    end

    it 'next due date is before Time.now for staggered deadline' do
      assignment_id = create(:assignment, staggered_deadline: true, name: 'TestAssignment3',
                                          directory_path: 'TestAssignment3').id
      due_date = create(:topic_due_date,
                        deadline_type: @deadline_type,
                        submission_allowed_id: @deadline_right,
                        review_allowed_id: @deadline_right,
                        review_of_review_allowed_id: @deadline_right,
                        due_at: Time.zone.now - 5000,
                        parent_id: assignment_id)
      expect(DueDateHelper.get_next_due_date(assignment_id, due_date.parent_id)).to be nil
    end

    it 'get next due date from assignment for staggered deadline' do
      assignment_id = create(:assignment, staggered_deadline: true, name: 'TestAssignment4',
                                          directory_path: 'TestAssignment4').id
      create(:assignment_due_date,
             deadline_type: @deadline_type,
             submission_allowed_id: @deadline_right,
             review_allowed_id: @deadline_right,
             review_of_review_allowed_id: @deadline_right,
             due_at: Time.zone.now + 5000,
             parent_id: assignment_id)
      expect(DueDateHelper.get_next_due_date(assignment_id)).to be_valid
    end
  end

  it 'metareview review_of_review_allowed default permission OK' do
    expect(DueDateHelper.default_permission('metareview', 'review_of_review_allowed')).to be == DeadlineRight::OK
  end

  it 'review submission_allowed default permission NO' do
    expect(DueDateHelper.default_permission('review', 'submission_allowed')).to be == DeadlineRight::NO
  end
end

describe "default_permission" do
  let(:permissions) { DeadlineRight::DEFAULT_PERMISSION }

  context "when deadline_type is 'signup' and permission_type is 'read'" do
    it "returns the default read permission for deadline type signup" do
      expect(permissions['signup']['submission_allowed']).to eq(DeadlineRight::OK)
      expect(permissions['signup']['can_review']).to eq(DeadlineRight::NO)
      expect(permissions['signup']['review_of_review_allowed']).to eq(DeadlineRight::NO)
    end
  end

  context "when deadline_type is 'signup' and permission_type is 'write'" do
    it "returns the default write permission for deadline type signup" do
      expect(permissions['signup']['can_review']).to eq(DeadlineRight::NO)
    end
  end

  context "when deadline_type is 'team_formation' and permission_type is 'read'" do
    it "returns the default read permission for deadline type team_formation" do
      expect(permissions['team_formation']['submission_allowed']).to eq(DeadlineRight::OK)
      expect(permissions['team_formation']['can_review']).to eq(DeadlineRight::NO)
      expect(permissions['team_formation']['review_of_review_allowed']).to eq(DeadlineRight::NO)
    end
  end

  context "when deadline_type is 'team_formation' and permission_type is 'write'" do
    it "returns the default write permission for deadline type team_formation" do
      expect(permissions['team_formation']['can_review']).to eq(DeadlineRight::NO)
    end
  end

  context "when deadline_type is 'submission' and permission_type is 'read'" do
    it "returns the default read permission for deadline type submission" do
      expect(permissions['submission']['submission_allowed']).to eq(DeadlineRight::OK)
      expect(permissions['submission']['can_review']).to eq(DeadlineRight::NO)
      expect(permissions['submission']['review_of_review_allowed']).to eq(DeadlineRight::NO)
    end
  end

  context "when deadline_type is 'submission' and permission_type is 'write'" do
    it "returns the default write permission for deadline type submission" do
      expect(permissions['submission']['can_review']).to eq(DeadlineRight::NO)
    end
  end
end