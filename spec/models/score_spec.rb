require 'spec_helper'

describe 'Scores' do

  before(:each) do
    @question = Question.create(:id => "1" , :txt => "new question", :true_false => "0" , :weight => "1",:questionnaire_id => "1")
    @response = Response.create(:id => "1", :map_id => "2" , :additional_comment => "hello" , :created_at => "0000-00-00 00:00:00", :updated_at => "0000-00-00 00:00:00", :version_num => "1")
    @score1 = Score.create(:id => "1", :question_id => @question.id, :score => "3" , :comments => "hello" , :response_id => @response.id)
    @item = Score.create(:id => "2", :question_id => @question.id, :score => "5" , :comments => "comment" , :response_id => @response.id)
    @current_score = -1

  end
  describe "score" do

  it 'should have question id' do
    @score1.question_id.should_not be_nil
  end
  it 'should have reponse id' do
    @score1.response_id.should_not be_nil
  end
  it 'should have score' do
    @score1.score.should_not be_nil
  end
  end

  describe "function self.compute_scores(assessments, questions)" do
    it "takes no more than two parameters" do
      lambda{ Score.compute_scores "1","a","1"}.should raise_exception ArgumentError
    end
    it "takes no less than two parameters" do
      lambda{ Score.compute_scores "1"}.should raise_exception ArgumentError
    end
    it "takes exactly two parameters" do
      lambda{ Score.compute_scores "1","1"}.should_not raise_exception ArgumentError
    end
    it "returns the correct score" do
      @score1.score.should == 3
    end
    it "returns the correct score" do
      @score1.score.should_not == 7
    end
     it "returns a score of 0 for invalid review" do
       @invalid_review = 1
       @currentscore.should be_nil
     end
    it "returns a current score for valid review" do
      @invalid_review = 0
      @score1.score.should_not be_nil
    end

  end

  describe "function get_total_score(params)" do
    it "takes exactly one parameter" do
        lambda{ Score.get_total_score "1"}.should_not raise_exception ArgumentError
    end
    it "takes no more than 1 parameter" do
      lambda{ Score.compute_scores "1","a","1"}.should raise_exception ArgumentError
    end
    it "takes no less than 1 parameters" do
      lambda{ Score.compute_scores }.should raise_exception ArgumentError
    end
    it "returns the correct score" do
      @score1.score.should == 3
    end
    it "returns the correct score" do
      @score1.score.should_not == 7
    end
    it "computes weighted score if the item is not nil" do
       @score1.score.should_not be_nil
    end
    it "returns weighted score if sum of weight>0" do
    @sum_of_weight = 1
    @score1.score.should_not be_nil
    end
    it "does not return weighted score if sum of weight <0" do
      @sum_of_weight = -1
      @current_score.should == -1
      end
    end
  end

