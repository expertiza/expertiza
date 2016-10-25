require 'rails_helper'

describe Questionnaire do
  let(:questionnaire) { Questionnaire.new name: "abc", private: 0, min_question_score: 0, max_question_score: 10, instructor_id: 1234 }
  let(:questionnaire1) { Questionnaire.new name: "xyz", private: 0, max_question_score: 20, instructor_id: 1234 }

  describe "#name" do
    it "returns the name of the Questionnaire" do
      expect(questionnaire.name).to eq("abc")
    end

    it "Validate presence of name which cannot be blank" do
      questionnaire.name = '  '
      expect(questionnaire).not_to be_valid
    end
  end

  describe "#instrucor_id" do
    it "returns the instructor id" do
      expect(questionnaire.instructor_id).to eq(1234)
    end
  end

  describe "#maximum_score" do
    it "validate maximum score" do
      expect(questionnaire.max_question_score).to eq(10)
    end

    it "validate maximum score is integer" do
      expect(questionnaire.max_question_score).to eq(10)
      questionnaire.max_question_score = 'a'
      expect(questionnaire).not_to be_valid
    end

    it "validate maximum should be positive" do
      expect(questionnaire.max_question_score).to eq(10)
      questionnaire.max_question_score = -10
      expect(questionnaire).not_to be_valid
      questionnaire.max_question_score = 10
    end
  end

  describe "#minimum_score" do
    it "validate minimum score" do
      questionnaire.min_question_score = 5
      expect(questionnaire.min_question_score).to eq(5)
    end

    it "validate default minimum score" do
      expect(questionnaire1.min_question_score).to eq(0)
    end

    it "validate minimum should be smaller than maximum" do
      expect(questionnaire.min_question_score).to eq(0)
      questionnaire.min_question_score = 10
      expect(questionnaire).not_to be_valid
      questionnaire.min_question_score = 0
    end
  end
end
