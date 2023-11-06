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
  let(:permissions) { Permission.default_permissions }

  context "when deadline_type is 'A' and permission_type is 'read'" do
    it "returns the default read permission for deadline type A" do
      expect(permissions.get_read_permission('A')).to eq('default_read_permission_for_A')
    end
  end

  context "when deadline_type is 'A' and permission_type is 'write'" do
    it "returns the default write permission for deadline type A" do
      expect(permissions.get_write_permission('A')).to eq('default_write_permission_for_A')
    end
  end

  context "when deadline_type is 'B' and permission_type is 'read'" do
    it "returns the default read permission for deadline type B" do
      expect(permissions.get_read_permission('B')).to eq('default_read_permission_for_B')
    end
  end

  context "when deadline_type is 'B' and permission_type is 'write'" do
    it "returns the default write permission for deadline type B" do
      expect(permissions.get_write_permission('B')).to eq('default_write_permission_for_B')
    end
  end

  context "when deadline_type is 'C' and permission_type is 'read'" do
    it "returns the default read permission for deadline type C" do
      expect(permissions.get_read_permission('C')).to eq('default_read_permission_for_C')
    end
  end

  context "when deadline_type is 'C' and permission_type is 'write'" do
    it "returns the default write permission for deadline type C" do
      expect(permissions.get_write_permission('C')).to eq('default_write_permission_for_C')
    end
  end
end

describe ".copy" do
  let(:old_assignment) { create(:assignment) }
  let(:new_assignment) { create(:assignment) }

  context "when copying due dates from an old assignment to a new assignment" do
    it "creates new due dates with the same attributes as the original due dates" do

      due_dates = create_list(:due_date, 2, assignment: old_assignment)
      single_due_date = create(:due_date, assignment: old_assignment)

      DueDate.copy(old_assignment.id, new_assignment.id)

      # Test scenario 1
      new_due_dates = DueDate.where(assignment_id: new_assignment.id)
      expect(new_due_dates.count).to eq 3
      new_due_dates.each_with_index do |new_due_date, index|
        expect(new_due_date.attributes.except('id', 'assignment_id', 'created_at', 'updated_at')).to eq due_dates[index].attributes.except('id', 'assignment_id', 'created_at', 'updated_at')
      end

      # Test scenario 2
      DueDate.delete_all
      expect { DueDate.copy(old_assignment.id, new_assignment.id) }.not_to change(DueDate, :count)

      # Test scenario 3
      new_single_due_date = DueDate.find_by(assignment_id: new_assignment.id)
      expect(new_single_due_date.attributes.except('id', 'assignment_id', 'created_at', 'updated_at')).to eq single_due_date.attributes.except('id', 'assignment_id', 'created_at', 'updated_at')
    end

    it "assigns the new assignment ID to the parent ID of the new due dates" do
      # Test scenario 1
      create_list(:due_date, 2, assignment: old_assignment)
      DueDate.copy(old_assignment.id, new_assignment.id)
      new_due_dates = DueDate.where(assignment_id: new_assignment.id)
      expect(new_due_dates.count).to eq 2
      expect(new_due_dates.pluck(:assignment_id).uniq).to eq [new_assignment.id]

      # Test scenario 2
      DueDate.delete_all
      expect { DueDate.copy(old_assignment.id, new_assignment.id) }.not_to change { DueDate.where(assignment_id: new_assignment.id).count }

      # Test scenario 3
      create(:due_date, assignment: old_assignment)
      DueDate.copy(old_assignment.id, new_assignment.id)
      new_single_due_date = DueDate.find_by(assignment_id: new_assignment.id)
      expect(new_single_due_date.assignment_id).to eq new_assignment.id
    end

    it "saves the new due dates" do
      # Test scenario 1
      create_list(:due_date, 2, assignment: old_assignment)
      expect { DueDate.copy(old_assignment.id, new_assignment.id) }.to change { DueDate.where(assignment_id: new_assignment.id).count }.by(2)

      # Test scenario 2
      DueDate.delete_all
      expect { DueDate.copy(old_assignment.id, new_assignment.id) }.not_to change(DueDate, :count)

      # Test scenario 3
      create(:due_date, assignment: old_assignment)
      expect { DueDate.copy(old_assignment.id, new_assignment.id) }.to change { DueDate.where(assignment_id: new_assignment.id).count }.by(1)
    end
  end
end

describe "#<=>" do
  let(:current_due_date) { DueDate.new(due_at: Time.now) }
  let(:earlier_due_date) { DueDate.new(due_at: 1.day.ago) }
  let(:later_due_date) { DueDate.new(due_at: 1.day.from_now) }
  let(:same_time_due_date) { DueDate.new(due_at: current_due_date.due_at) }
  let(:no_due_date) { DueDate.new }

  context "when both objects have a due_at attribute" do
    it "returns -1 if the current object's due_at is earlier than the other object's due_at" do
      expect(current_due_date.<=>(later_due_date)).to eq(-1)
    end

    it "returns 0 if the current object's due_at is the same as the other object's due_at" do
      expect(current_due_date.<=>(same_time_due_date)).to eq(0)
    end

    it "returns 1 if the current object's due_at is later than the other object's due_at" do
      expect(current_due_date.<=>(earlier_due_date)).to eq(1)
    end
  end

  context "when only the current object has a due_at attribute" do
    it "returns -1" do
      expect(current_due_date.<=>(no_due_date)).to eq(-1)
    end
  end

  context "when only the other object has a due_at attribute" do
    it "returns 1" do
      expect(no_due_date.<=>(current_due_date)).to eq(1)
    end
  end
end