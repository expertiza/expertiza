require 'rails_helper'
require './app/helpers/sign_up_sheet_helper.rb'

RSpec.configure do |c|
  c.include SignUpSheetHelper
end

describe "SignUpSheetHelper" do
  before(:each) do
    @deadline_type = build(:deadline_type)
    @deadline_right = build(:deadline_right)
    @topic_due_date = create(:topic_due_date, deadline_type: @deadline_type,
                             submission_allowed_id: @deadline_right.id, review_allowed_id: @deadline_right.id,
                             review_of_review_allowed_id: @deadline_right.id)
    @assignment_due_date= build(:assignment_due_date)
    @assignment_due_date.due_at="2015-12-31 23:30:12"
  end
  
   describe "#check_topic_due_date_value" do
    it "should pass because topic 1 has a specific deadline" do
      expect(check_topic_due_date_value([@assignment_due_date], 1,1,1)).to be == "2015-12-30 23:30"
    end
    it "should pass because topic 2 has a specific deadline" do
      expect(check_topic_due_date_value([@assignment_due_date], 2,1,1)).to be == "2015-12-31 23:30"
    end

   end


end
