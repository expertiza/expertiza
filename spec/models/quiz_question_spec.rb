require 'rails_helper'

describe QuizQuestion do

  #let(:quiz_question){QuizQuestion.new id: 1, txt: "In which city is NCSU located?"}
  before(:each) do
    @q = QuizQuestion.new
    @q.id = 1
    @q.txt = "In which city is NCSU located?"

    @q_c1 = QuizQuestionChoice.new
    @q_c1.txt = "Raleigh"
    @q_c1.iscorrect = true

    @q_c2 = QuizQuestionChoice.new
    @q_c2.txt = "Atlanta"

    @q_c3 = QuizQuestionChoice.new
    @q_c3.txt = "Charlotte"

    @q_c4 = QuizQuestionChoice.new
    @q_c4.txt = "North Carolina"

    @q.quiz_question_choices << @q_c1
    @q.quiz_question_choices << @q_c2
    @q.quiz_question_choices << @q_c3
    @q.quiz_question_choices << @q_c4

  end

  describe "#new" do
    it "creates a new instance of QuizQuestion" do
      expect(@q.class).to be(QuizQuestion)
    end
  end

  describe "#txt" do
    it "returns the text of the question" do
      expect(@q.txt).to eq("In which city is NCSU located?")
    end
  end

  describe "view_question_text" do
    it "contains the text of the question" do
      expect(@q.view_question_text.html_safe).to include("In which city is NCSU located?")
    end

    it "contains each of the choices" do
      expect(@q.view_question_text.html_safe).to include("Raleigh")
      expect(@q.view_question_text.html_safe).to include("Atlanta")
      expect(@q.view_question_text.html_safe).to include("Charlotte")
      expect(@q.view_question_text.html_safe).to include("North Carolina")
    end

    it "bolds the correct answer" do
      expect(@q.view_question_text.html_safe).to include("<b>Raleigh</b>")
    end

    it "does not bold incorrect answers" do
      expect(@q.view_question_text.html_safe).not_to include("<b>Atlanta</b>")
      expect(@q.view_question_text.html_safe).not_to include("<b>Charlotte</b>")
      expect(@q.view_question_text.html_safe).not_to include("<b>North Carolina</b>")
    end
  end
end
