require 'rails_helper'

describe QuizQuestion do

  let(:quiz_question){QuizQuestion.new id: 1, txt: "In which city is NCSU located?"}

  describe "#new" do
    it "Validate quiz question instance creation with valid parameters" do
      expect(quiz_question.class).to be(QuizQuestion)
    end
  end

  describe "#txt" do
    it "it returns the text of the question" do
      expect(quiz_question.txt).to eq("In which city is NCSU located?")
    end
  end
end
