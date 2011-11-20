class AddRowsToQuestionAdvices < ActiveRecord::Migration
  def self.up
    QuestionAdvice.create :question_id => 1669, :score => 0, :advice => "Option1"
    QuestionAdvice.create :question_id => 1669, :score => 0, :advice => "Option2"
    QuestionAdvice.create :question_id => 1669, :score => 1, :advice => "Option3"
    QuestionAdvice.create :question_id => 1669, :score => 0, :advice => "Option4"

    QuestionAdvice.create :question_id => 1670, :score => 0, :advice => "Option1"
    QuestionAdvice.create :question_id => 1670, :score => 1, :advice => "Option2"
    QuestionAdvice.create :question_id => 1670, :score => 0, :advice => "Option3"
    QuestionAdvice.create :question_id => 1670, :score => 0, :advice => "Option4"

    QuestionAdvice.create :question_id => 1671, :score => 1, :advice => "Option1"
    QuestionAdvice.create :question_id => 1671, :score => 0, :advice => "Option2"
    QuestionAdvice.create :question_id => 1671, :score => 0, :advice => "Option3"
    QuestionAdvice.create :question_id => 1671, :score => 0, :advice => "Option4"

    QuestionAdvice.create :question_id => 1672, :score => 0, :advice => "Option1"
    QuestionAdvice.create :question_id => 1672, :score => 0, :advice => "Option2"
    QuestionAdvice.create :question_id => 1672, :score => 0, :advice => "Option3"
    QuestionAdvice.create :question_id => 1672, :score => 1, :advice => "Option4"

    QuestionAdvice.create :question_id => 1673, :score => 0, :advice => "Option1"
    QuestionAdvice.create :question_id => 1673, :score => 0, :advice => "Option2"
    QuestionAdvice.create :question_id => 1673, :score => 0, :advice => "Option3"
    QuestionAdvice.create :question_id => 1673, :score => 1, :advice => "Option4"

    QuestionAdvice.create :question_id => 1674, :score => 1, :advice => "Option1"
    QuestionAdvice.create :question_id => 1674, :score => 0, :advice => "Option2"
    QuestionAdvice.create :question_id => 1674, :score => 0, :advice => "Option3"
    QuestionAdvice.create :question_id => 1674, :score => 0, :advice => "Option4"

    QuestionAdvice.create :question_id => 1675, :score => 0, :advice => "Option1"
    QuestionAdvice.create :question_id => 1675, :score => 0, :advice => "Option2"
    QuestionAdvice.create :question_id => 1675, :score => 0, :advice => "Option3"
    QuestionAdvice.create :question_id => 1675, :score => 1, :advice => "Option4"

    QuestionAdvice.create :question_id => 1676, :score => 0, :advice => "Option1"
    QuestionAdvice.create :question_id => 1676, :score => 1, :advice => "Option2"
    QuestionAdvice.create :question_id => 1676, :score => 0, :advice => "Option3"
    QuestionAdvice.create :question_id => 1676, :score => 0, :advice => "Option4"

    QuestionAdvice.create :question_id => 1677, :score => 1, :advice => "Option1"
    QuestionAdvice.create :question_id => 1677, :score => 0, :advice => "Option2"
    QuestionAdvice.create :question_id => 1677, :score => 0, :advice => "Option3"
    QuestionAdvice.create :question_id => 1677, :score => 0, :advice => "Option4"

  end

  def self.down
  end
end
