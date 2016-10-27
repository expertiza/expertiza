require 'rails_helper'
require 'pp'
require 'spec_helper'
require 'factory_girl_rails'

describe "DeadlineHelper" do

  RSpec.configure do |config|
    config.include FactoryGirl::Syntax::Methods
  end

  before(:each) do
    @deadline_type = create(:deadline_type)
    @deadline_right = create(:deadline_right)
    @topic_due_date = create(:topic_due_date, deadline_type: @deadline_type,
      submission_allowed_id: @deadline_right.id, review_allowed_id: @deadline_right.id,
      review_of_review_allowed_id: @deadline_right.id)
  end

  it "check due date flag should be set" do
    expect(@topic_due_date.flag).to be false
    @topic_due_date.set_flag
    expect(@topic_due_date.flag).to be true
  end
 
  it "has a valid factory" do
    factory = FactoryGirl.build(:topic_due_date)
    expect(factory).to be_valid
    #create(:topic_due_date).should be_valid
  end

  it "check valid datetime for due date" do
    expect(@topic_due_date.due_at_is_valid_datetime).to be nil
  end
 
end
