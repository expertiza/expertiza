describe 'due_date_functions' do
  before(:each) do
    @deadline_type = build(:deadline_type)
    @deadline_right = build(:deadline_right)
    @assignment_due_date = build(:assignment_due_date, deadline_type: @deadline_type,
                                                       submission_allowed_id: @deadline_right.id, review_allowed_id: @deadline_right.id,
                                                       review_of_review_allowed_id: @deadline_right.id, due_at: '2015-12-30 23:30:12')

    @due_dates = []
    10.times.each do |n|
      date = if n == 1 || n == 9
               nil
             else
               Time.zone.now - 60 * n
             end
      @due_dates << build(:assignment_due_date, due_at: date)
    end
  end

  it 'due date factory created successfully' do
    expect(@assignment_due_date).to be_valid
  end

  it 'due dates created correctly' do
    expect(@due_dates.length).to be == 10
  end

  it 'due date flag is set' do
    expect(@assignment_due_date.flag).to be false
    @assignment_due_date.set_flag
    expect(@assignment_due_date.flag).to be true
  end

  it 'due at is valid datetime' do
    expect(@assignment_due_date.due_at_is_valid_datetime).to be nil
  end

  it 'copy due dates to new assignment' do
    new_assignment_id = build(:assignment, id: 999).id
    old_assignment_id = @assignment_due_date.assignment.id
    DueDateHelper.copy(old_assignment_id, new_assignment_id)
    expect(DueDate.where(parent_id: new_assignment_id).count).to eql DueDate.where(parent_id: old_assignment_id).count
  end

  it 'create new duedate record with values' do
    DueDateHelper.set_due_date({ id: 999 }, @assignment_due_date.deadline_type_id,
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
      due_date = create(:assignment_due_date, deadline_type: @deadline_type,
                                              submission_allowed_id: @deadline_right.id, review_allowed_id: @deadline_right.id,
                                              review_of_review_allowed_id: @deadline_right.id, due_at: Time.zone.now + 5000)
      expect(DueDateHelper.get_next_due_date(due_date.parent_id)).to be_valid
    end

    it 'get next due date from topic for staggered deadline' do
      assignment_id = create(:assignment, staggered_deadline: true, name: 'TestAssignment1', directory_path: 'TestAssignment1').id
      due_date = create(:topic_due_date, deadline_type: @deadline_type,
                                         submission_allowed_id: @deadline_right.id, review_allowed_id: @deadline_right.id,
                                         review_of_review_allowed_id: @deadline_right.id, due_at: Time.zone.now + 5000, parent_id: assignment_id)
      expect(DueDateHelper.get_next_due_date(assignment_id, due_date.parent_id)).to be_valid
    end

    it 'next due date does not exist for staggered deadline' do
      assignment_id = create(:assignment, staggered_deadline: true, name: 'TestAssignment2', directory_path: 'TestAssignment2').id
      expect(DueDateHelper.get_next_due_date(assignment_id)).to be nil
    end

    it 'next due date is before Time.now for staggered deadline' do
      assignment_id = create(:assignment, staggered_deadline: true, name: 'TestAssignment3', directory_path: 'TestAssignment3').id
      due_date = create(:topic_due_date, deadline_type: @deadline_type,
                                         submission_allowed_id: @deadline_right, review_allowed_id: @deadline_right,
                                         review_of_review_allowed_id: @deadline_right, due_at: Time.zone.now - 5000, parent_id: assignment_id)
      expect(DueDateHelper.get_next_due_date(assignment_id, due_date.parent_id)).to be nil
    end

    it 'get next due date from assignment for staggered deadline' do
      assignment_id = create(:assignment, staggered_deadline: true, name: 'TestAssignment4', directory_path: 'TestAssignment4').id
      due_date = create(:assignment_due_date, deadline_type: @deadline_type,
                                              submission_allowed_id: @deadline_right, review_allowed_id: @deadline_right,
                                              review_of_review_allowed_id: @deadline_right, due_at: Time.zone.now + 5000, parent_id: assignment_id)
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
