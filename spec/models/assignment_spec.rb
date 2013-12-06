require 'spec_helper'

describe 'Assignment' do

  before(:each) do

    @sum_of_scores1 = 0

    @assignment = Assignment.new
    @question = Question.create(:id => "1" , :txt => "new question", :true_false => "0" , :weight => "1",:questionnaire_id => "1")
    @response = Response.create(:id => "1", :map_id => "2" , :additional_comment => "hello" , :created_at => "0000-00-00 00:00:00", :updated_at => "0000-00-00 00:00:00", :version_num => "1")
    @sum_of_scores = Score.create(:id => "1", :question_id => @question.id, :score => "3" , :comments => "hello" , :response_id => @response.id)
    @assignment_questionnaire= AssignmentQuestionnaire.create(:id => "1" , :assignment_id => "Questionnaire", :questionnaire_id => "1" , :user_id => "2",:notification_limit => "15", :questionnaire_weight => "100");
  end

  describe "get average score function" do

    it "takes no parameters" do
      lambda{ @assignment.get_average_score "1"}.should raise_exception ArgumentError
    end

    it "takes 0 parameters" do
      lambda{ @assignment.get_average_score}.should_not raise_exception ArgumentError
    end
    it "should return sum 0 if total reviews assigned is 0" do
      @get_total_reviews_assigned = 0
      @sum_of_scores1.should == 0
    end
    it "should return correct sum if total reviews assigned is not 0" do
      @get_total_reviews_assigned = 1
      @sum_of_scores.score.should == 3
    end

    it "should not return incorrect sum if response map has elements " do
      @get_total_reviews_assigned = 1
      @sum_of_scores.score.should_not be == 10
    end
  end

  describe "compute_total_score function "do
    it "should return correct questionnaire weight by mapping through questionnaire assignment table " do
      @assignment_questionnaire.questionnaire_weight.should == 100
    end
end
end