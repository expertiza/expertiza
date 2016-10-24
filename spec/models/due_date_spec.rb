require 'rails_helper'
require 'pp'

describe "due_date_functions" do

  before(:each) do
    create(:deadline_type)
    @assignment_due_date = create(:assignment_due_date)

    @due_dates = []
    10.times.each do |n|
      if n == 1 || n == 9
        date = nil
      else
        date = Time.zone.now - 60*n
      end
      @due_dates << build(:assignment_due_date, due_at: date)
    end
  end

  it "due date flag is set" do
    expect(@assignment_due_date.flag).to be false
    @assignment_due_date.set_flag
    expect(@assignment_due_date.flag).to be true
  end

  it "due at is valid datetime" do
    expect(@assignment_due_date.due_at_is_valid_datetime).to be nil
  end

  it "copy due dates to new assignment" do
    new_assignment_id = build(:assignment, id: 999).id
    old_assignment_id = @assignment_due_date.assignment.id
    DueDate.copy(old_assignment_id, new_assignment_id)
    expect(DueDate.where(parent_id: new_assignment_id).count).to eql DueDate.where(parent_id: old_assignment_id).count
  end

  it "create new duedate record with values" do
    DueDate.set_duedate({id: 999}, @assignment_due_date.deadline_type_id,
                        @assignment_due_date.parent_id, @assignment_due_date.round)
    new_due_date = DueDate.find_by(id: 999)
    expect(new_due_date).to be_valid
    expect(new_due_date.deadline_type_id).to eql @assignment_due_date.deadline_type_id
    expect(new_due_date.parent_id).to eql @assignment_due_date.parent_id
    expect(new_due_date.round).to eql @assignment_due_date.round
  end

  it "sort duedate records" do
    sorted_due_dates = @due_dates
    expect(sorted_due_dates.each_cons(2).all?{|m1, m2| (m1.due_at <=> m2.due_at) != 1}).to eql false

    sorted_due_dates = DueDate.deadline_sort(@due_dates)
    expect(sorted_due_dates.each_cons(2).all?{|m1, m2| (m1.due_at <=> m2.due_at) != 1}).to eql true
  end

  describe "#done_in_assignment_round" do
    it "return 0 when no response map" do
      response = ReviewResponseMap.create
      response.type = "ResponseMap"
      response.save
      expect(DueDate.done_in_assignment_round(1, response)).to eql 0
    end

    it "return round 1 for single round" do
      response = ReviewResponseMap.create
      expect(DueDate.done_in_assignment_round(@assignment_due_date.parent_id, response)).to eql 1
    end
  end

  describe "#get_next_due_date" do
    it "no subsequent due date" do
      expect(DueDate.get_next_due_date(@assignment_due_date.parent_id)).to be nil
    end

    it "nil value throws exception" do
      expect { DueDate.get_next_due_date(nil) }.to raise_exception(ActiveRecord::RecordNotFound)
    end

    it "get next due date" do
      due_date = create(:assignment_due_date, due_at: Time.zone.now + 5000)
      expect(DueDate.get_next_due_date(due_date.parent_id)).to be_valid
    end

    it "get due date for staggered deadline" do
      assignment_id = create(:assignment, staggered_deadline: true, name: "testassignment").id
      due_date = create(:assignment_due_date, due_at: Time.zone.now + 5000, parent_id: assignment_id)
      expect(DueDate.get_next_due_date(assignment_id)).to be_valid
    end
  end

end
