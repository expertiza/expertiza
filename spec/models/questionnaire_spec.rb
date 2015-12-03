require "spec_helper"

describe Questionnaire do
  before :each do
    @questionnaire = Questionnaire.new name: "abc", private: 0, min_question_score:0,max_question_score:10, instructor_id:1234
  end

  describe "#name" do
    it "returns the name of the Questionnaire" do
      @questionnaire.name.should eql "abc"
    end
    it "Validate presence of name which cannot be blank" do
      questionnaire1 = Questionnaire.new private: 0, min_question_score:0,max_question_score:10, instructor_id:1234
      questionnaire1.should_not be_valid
    end
  end

  describe "#instrucor_id" do
    it "returns the instructor id" do
      @questionnaire.instructor_id.should eql 1234
    end
  end

  describe "maximum_score" do
    it "validate maximum score" do
      @questionnaire.max_question_score.should eql 10
    end
    it "validate maximum score is integer" do
      questionnaire1 = Questionnaire.new name: "abc", private: 0, min_question_score:"a", max_question_score:10, instructor_id:1234
      @questionnaire.max_question_score.should eql 10
    end

  end

  describe "minimum_score" do
    it "validate minimum score" do
      questionnaire1 = Questionnaire.new name: "abc", private: 0, min_question_score:5, max_question_score:10, instructor_id:1234
      questionnaire1.min_question_score.should eql 5
    end
    it "validate default maximum score" do
      questionnaire1 = Questionnaire.new name: "xyz",private: 0, max_question_score:20,instructor_id:1234
      questionnaire1.min_question_score.should eql 0
    end
  end
end