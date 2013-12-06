require 'spec_helper'

describe 'AssignmentQuestionnaire' do

  before(:each) do
    @metareview_questionnaire= AssignmentQuestionnaire.create(:id => "1" , :assignment_id => "MetareviewQuestionnaire", :questionnaire_id => "1" , :user_id => "2",:notification_limit => "15", :questionnaire_weight => "100");
    @review_questionnaire= AssignmentQuestionnaire.create(:id => "1" , :assignment_id => "ReviewQuestionnaire", :questionnaire_id => "1" , :user_id => "2",:notification_limit => "15", :questionnaire_weight => "200");
    @feedback_questionnaire= AssignmentQuestionnaire.create(:id => "1" , :assignment_id => "FeedbackQuestionnaire", :questionnaire_id => "1" , :user_id => "2",:notification_limit => "15", :questionnaire_weight => "300");
    @teammatereview_questionnaire= AssignmentQuestionnaire.create(:id => "1" , :assignment_id => "TeammateReviewQuestionnaire", :questionnaire_id => "1" , :user_id => "2",:notification_limit => "15", :questionnaire_weight => "400");

  end
  describe "weight function for metareview questionnaire" do
    it "should return correct questionnaire weight" do
        @metareview_questionnaire.questionnaire_weight.should == 100
    end
    it "should not return incorrect weight for questionnaire" do
      @metareview_questionnaire.questionnaire_weight.should_not be == 200
    end
  end
  describe "weight function for review questionnaire" do
    it "should return correct questionnaire weight" do
      @review_questionnaire.questionnaire_weight.should == 200
    end
    it "should not return incorrect weight for questionnaire" do
      @review_questionnaire.questionnaire_weight.should_not be == 300
    end
  end

  describe "weight function for author feedback questionnaire" do
    it "should return correct questionnaire weight" do
      @feedback_questionnaire.questionnaire_weight.should == 300
    end
    it "should not return incorrect weight for questionnaire" do
      @feedback_questionnaire.questionnaire_weight.should_not be == 200
    end
  end

  describe "weight function for teammate review questionnaire" do
    it "should return correct questionnaire weight" do
      @teammatereview_questionnaire.questionnaire_weight.should == 400
    end
    it "should not return incorrect weight for questionnaire" do
      @teammatereview_questionnaire.questionnaire_weight.should_not be == 200
    end
  end

end
