require 'spec_helper'

describe 'Participant' do

  before(:each) do

    @sum_of_scores1 = 0
    @participant = Participant.new
    @question = Question.create(:id => "1" , :txt => "new question", :true_false => "0" , :weight => "1",:questionnaire_id => "1")
    @response = Response.create(:id => "1", :map_id => "2" , :additional_comment => "hello" , :created_at => "0000-00-00 00:00:00", :updated_at => "0000-00-00 00:00:00", :version_num => "1")
    @sum_of_scores = Score.create(:id => "1", :question_id => @question.id, :score => "3" , :comments => "hello" , :response_id => @response.id)
  end
  describe "get average score function" do

    it "takes no parameters" do
      lambda{ @participant.get_average_score "1"}.should raise_exception ArgumentError
    end

    it "takes 0 parameters" do
      lambda{ @participant.get_average_score}.should_not raise_exception ArgumentError
    end
    it "should return sum 0 if response map is empty" do
      @response_maps_size = 0
      @sum_of_scores1.should == 0
    end
    it "should return correct sum if response map has elements " do
      @response_maps_size == 4
      @sum_of_scores.score.should == 3
    end

    it "should not return incorrect sum if response map has elements " do
      @response_maps_size == 4
      @sum_of_scores.score.should_not be == 10
    end
  end
  describe " get average score per assignment" do
    it "takes no more than one parameter" do
      lambda{ @participant.get_average_score_per_assignment "1","a","1"}.should raise_exception ArgumentError
    end
    it "takes no less than one parameter" do
      lambda{ @participant.get_average_score_per_assignment }.should raise_exception ArgumentError
    end
    it "should return sum 0 if response map is empty" do
      @response_maps_size = 0
      @sum_of_scores1.should == 0
    end
    it "should return correct sum if response map has elements " do
      @response_maps_size == 4
      @sum_of_scores.score.should == 3
    end

    it "should not return incorrect sum if response map has elements " do
      @response_maps_size == 4
      @sum_of_scores.score.should_not be == 10
    end
  end
end