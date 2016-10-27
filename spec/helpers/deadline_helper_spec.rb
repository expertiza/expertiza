require 'rails_helper'
require 'pp'
require 'spec_helper'
require 'factory_girl_rails'

describe "DeadlineHelper" do

  RSpec.configure do |config|
    config.include FactoryGirl::Syntax::Methods
  end

  before(:each) do
    create(:deadline_type)
    @topic_due_date = create(:topic_due_date)
    @due_dates = []
    10.times.each do |n|
      if n==1 || n==9
        date = nil
      else
        date = Time.zone.now - 60*n
      end
      @due_dates << build(:assignment_due_date, due_at:date)
    end
  end

  it "due date flag is set" do
    expect(@topic_due_date.flag).to be false
    @topic_due_date.set_flag
    expect(@topic_due_date.flag).to be true
  end
 
  it "has a valid factory" do
    factory = FactoryGirl.build(:topic_due_date)
    expect(factory).to be_valid
    #create(:topic_due_date).should be_valid
  end

  it "due date is a valid datetime" do
    expect(@topic_due_date.due_at_is_valid_datetime).to be nil
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
      expect(DueDate.done_in_assignment_round(@topic_due_date.parent_id, response)).to eql 1
    end
  end

  describe "#get_next_due_date" do


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

