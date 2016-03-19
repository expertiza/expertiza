require 'rails_helper'

describe QuizQuestion do

  #Create a multiple-choice radio question and assign it four choices
  before(:each) do
    @question = MultipleChoiceRadio.new
    @question.id = 1
    @question.txt = "In which city is NCSU located?"

    @question_choice1 = QuizQuestionChoice.new
    @question_choice1.txt = "Raleigh"
    @question_choice1.iscorrect = true

    @question_choice2 = QuizQuestionChoice.new
    @question_choice2.txt = "Atlanta"
    @question_choice2.iscorrect = false

    @question_choice3 = QuizQuestionChoice.new
    @question_choice3.txt = "Charlotte"
    @question_choice3.iscorrect = false

    @question_choice4 = QuizQuestionChoice.new
    @question_choice4.txt = "North Carolina"
    @question_choice4.iscorrect = false

    @question.quiz_question_choices << @question_choice1
    @question.quiz_question_choices << @question_choice2
    @question.quiz_question_choices << @question_choice3
    @question.quiz_question_choices << @question_choice4

  end

  describe "#new" do
    it "creates a new instance of MultipleChoiceRadio" do
      expect(@question.class).to be(MultipleChoiceRadio)
    end
  end

  describe "#txt" do
    it "returns the text of the question" do
      expect(@question.txt).to eq("In which city is NCSU located?")
    end
  end

  describe "view_question_text" do
    it "contains the text of the question" do
      expect(@question.view_question_text.html_safe).to include("In which city is NCSU located?")
    end

    it "contains each of the choices" do
      expect(@question.view_question_text.html_safe).to include("Raleigh")
      expect(@question.view_question_text.html_safe).to include("Atlanta")
      expect(@question.view_question_text.html_safe).to include("Charlotte")
      expect(@question.view_question_text.html_safe).to include("North Carolina")
    end

    it "bolds the correct answer" do
      expect(@question.view_question_text.html_safe).to include("<b>Raleigh</b>")
    end

    it "does not bold incorrect answers" do
      expect(@question.view_question_text.html_safe).not_to include("<b>Atlanta</b>")
      expect(@question.view_question_text.html_safe).not_to include("<b>Charlotte</b>")
      expect(@question.view_question_text.html_safe).not_to include("<b>North Carolina</b>")
    end
  end
end
