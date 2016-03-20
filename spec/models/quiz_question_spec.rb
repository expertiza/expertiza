require 'rails_helper'

describe QuizQuestion do

  #Create a multiple-choice radio question and assign it four choices
  before(:each) do
    setup_radio_question()
    setup_checkbox_question()
    setup_true_false_question()
  end

  def setup_radio_question
    @radio_question = MultipleChoiceRadio.new
    @radio_question.id = 1
    @radio_question.txt = "In which city is NCSU located?"

    @radio_question_choice1 = QuizQuestionChoice.new
    @radio_question_choice1.question_id = @radio_question.id
    @radio_question_choice1.txt = "Raleigh"
    @radio_question_choice1.iscorrect = true

    @radio_question_choice2 = QuizQuestionChoice.new
    @radio_question_choice2.question_id = @radio_question.id
    @radio_question_choice2.txt = "Atlanta"
    @radio_question_choice2.iscorrect = false

    @radio_question_choice3 = QuizQuestionChoice.new
    @radio_question_choice3.question_id = @radio_question.id
    @radio_question_choice3.txt = "Charlotte"
    @radio_question_choice3.iscorrect = false

    @radio_question_choice4 = QuizQuestionChoice.new
    @radio_question_choice4.question_id = @radio_question.id
    @radio_question_choice4.txt = "North Carolina"
    @radio_question_choice4.iscorrect = false

    @radio_question.quiz_question_choices << @radio_question_choice1
    @radio_question.quiz_question_choices << @radio_question_choice2
    @radio_question.quiz_question_choices << @radio_question_choice3
    @radio_question.quiz_question_choices << @radio_question_choice4
  end

  def setup_checkbox_question
    @checkbox_question = MultipleChoiceCheckbox.new
    @checkbox_question.id = 2
    @checkbox_question.txt = "Which of the following are colors?"

    @checkbox_question_choice1 = QuizQuestionChoice.new
    @checkbox_question_choice1.txt = "Paint"
    @checkbox_question_choice1.iscorrect = false

    @checkbox_question_choice2 = QuizQuestionChoice.new
    @checkbox_question_choice2.txt = "Blue"
    @checkbox_question_choice2.iscorrect = true

    @checkbox_question_choice3 = QuizQuestionChoice.new
    @checkbox_question_choice3.txt = "Car"
    @checkbox_question_choice3.iscorrect = false

    @checkbox_question_choice4 = QuizQuestionChoice.new
    @checkbox_question_choice4.txt = "Red"
    @checkbox_question_choice4.iscorrect = true

    @checkbox_question.quiz_question_choices << @checkbox_question_choice1
    @checkbox_question.quiz_question_choices << @checkbox_question_choice2
    @checkbox_question.quiz_question_choices << @checkbox_question_choice3
    @checkbox_question.quiz_question_choices << @checkbox_question_choice4
  end

  def setup_true_false_question
    @true_false_question = TrueFalse.new
    @true_false_question.id = 3
    @true_false_question.txt = "2+2=4"

    @true_false_question_choice1 = QuizQuestionChoice.new
    @true_false_question_choice1.txt = "True"
    @true_false_question_choice1.iscorrect = true

    @true_false_question_choice2 = QuizQuestionChoice.new
    @true_false_question_choice2.txt = "False"
    @true_false_question_choice2.iscorrect = false

    @true_false_question.quiz_question_choices << @true_false_question_choice1
    @true_false_question.quiz_question_choices << @true_false_question_choice2
  end

  describe "#new" do
    it "creates a new instance of MultipleChoiceRadio" do
      expect(@radio_question.class).to be(MultipleChoiceRadio)
    end
  end

  describe "#txt" do
    it "returns the text of the question" do
      expect(@radio_question.txt).to eq("In which city is NCSU located?")
    end
  end

  describe "view_question_text" do
    context "when the question is a multiple-choice radio" do
      it "contains the text of the question" do
        expect(@radio_question.view_question_text.html_safe).to include("In which city is NCSU located?")
      end

      it "contains each of the choices" do
        expect(@radio_question.view_question_text.html_safe).to include("Raleigh")
        expect(@radio_question.view_question_text.html_safe).to include("Atlanta")
        expect(@radio_question.view_question_text.html_safe).to include("Charlotte")
        expect(@radio_question.view_question_text.html_safe).to include("North Carolina")
      end

      it "bolds the correct answer" do
        expect(@radio_question.view_question_text.html_safe).to include("<b>Raleigh</b>")
      end

      it "does not bold incorrect answers" do
        expect(@radio_question.view_question_text.html_safe).not_to include("<b>Atlanta</b>")
        expect(@radio_question.view_question_text.html_safe).not_to include("<b>Charlotte</b>")
        expect(@radio_question.view_question_text.html_safe).not_to include("<b>North Carolina</b>")
      end
    end

    context "when the question is a multiple-choice checkbox" do
      it "contains the text of the question" do
        expect(@checkbox_question.view_question_text.html_safe).to include("Which of the following are colors?")
      end

      it "contains each of the choices" do
        expect(@checkbox_question.view_question_text.html_safe).to include("Paint")
        expect(@checkbox_question.view_question_text.html_safe).to include("Blue")
        expect(@checkbox_question.view_question_text.html_safe).to include("Car")
        expect(@checkbox_question.view_question_text.html_safe).to include("Red")
      end

      it "bolds the correct answers" do
        expect(@checkbox_question.view_question_text.html_safe).to include("<b>Blue</b>")
        expect(@checkbox_question.view_question_text.html_safe).to include("<b>Red</b>")
      end

      it "does not bold incorrect answers" do
        expect(@checkbox_question.view_question_text.html_safe).not_to include("<b>Paint</b>")
        expect(@checkbox_question.view_question_text.html_safe).not_to include("<b>Car</b>")
      end
    end

    context "when the question is true/false" do
      it "contains the text of the question" do
        expect(@true_false_question.view_question_text.html_safe).to include("2+2=4")
      end

      it "contains each of the choices" do
        expect(@true_false_question.view_question_text.html_safe).to include("True")
        expect(@true_false_question.view_question_text.html_safe).to include("False")
      end

      it "bolds the correct answer" do
        expect(@true_false_question.view_question_text.html_safe).to include("<b>True</b>")
      end

      it "does not bold the incorrect answer" do
        expect(@true_false_question.view_question_text.html_safe).not_to include("<b>False</b>")
      end
    end
  end

  describe "edit" do
    context "when the question is a multiple-choice radio" do
      it "contains the text of the question within a textarea tag" do
        expect(@radio_question.edit(0)).to include("In which city is NCSU located?</textarea>")
      end

      it "contains each of the choices" do
        expect(@radio_question.edit(0)).to include("Raleigh")
        expect(@radio_question.edit(0)).to include("Atlanta")
        expect(@radio_question.edit(0)).to include("Charlotte")
        expect(@radio_question.edit(0)).to include("North Carolina")
      end

      it "puts each choice in a radio button" do
        expect(@radio_question.edit(0).scan('input type="radio"').size).to eq(4)
      end

      it "selects only the correct answer" do
        expect(@radio_question.edit(0)).to include('value="1" checked="checked"')
      end

      it "does not select the incorrect answers" do
        expect(@radio_question.edit(0)).to include('value="2" />')
        expect(@radio_question.edit(0)).to include('value="3" />')
        expect(@radio_question.edit(0)).to include('value="4" />')
      end
    end

    context "when the question is a multiple-choice checkbox" do
      it "contains the text of the question within a textarea tag" do
        expect(@checkbox_question.edit(0)).to include("Which of the following are colors?</textarea>")
      end

      it "contains each of the choices" do
        expect(@checkbox_question.edit(0)).to include("Paint")
        expect(@checkbox_question.edit(0)).to include("Blue")
        expect(@checkbox_question.edit(0)).to include("Car")
        expect(@checkbox_question.edit(0)).to include("Red")
      end

      it "puts each choice in a check box" do
        expect(@checkbox_question.edit(0).scan('input type="checkbox"').size).to eq(4)
      end

      it "checks only the correct answers" do
        expect(@checkbox_question.edit(0)).to include('id="quiz_question_choices_2_MultipleChoiceCheckbox_2_iscorrect" value="1" checked="checked"')
        expect(@checkbox_question.edit(0)).to include('id="quiz_question_choices_2_MultipleChoiceCheckbox_4_iscorrect" value="1" checked="checked"')
      end

      it "does not check the incorrect answers" do
        expect(@checkbox_question.edit(0)).to include('id="quiz_question_choices_2_MultipleChoiceCheckbox_1_iscorrect" value="1" />')
        expect(@checkbox_question.edit(0)).to include('id="quiz_question_choices_2_MultipleChoiceCheckbox_3_iscorrect" value="1" />')
      end
    end

    context "when the question is true/false" do
      it "contains the text of the question within a textarea tag" do
        expect(@true_false_question.edit(0)).to include("2+2=4</textarea>")
      end

      it "contains each of the choices" do
        expect(@true_false_question.edit(0)).to include("True")
        expect(@true_false_question.edit(0)).to include("False")
      end

      it "puts each choice in a radio button" do
        expect(@true_false_question.edit(0).scan('input type="radio"').size).to eq(2)
      end

      it "selects only the correct answer" do
        expect(@true_false_question.edit(0)).to include('value="True" checked="checked"')
      end

      it "does not select the incorrect answer" do
        expect(@true_false_question.edit(0)).to include('value="False" />')
      end
    end
  end
end
