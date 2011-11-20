class AddRowsToQuestions < ActiveRecord::Migration
  def self.up
    Question.create :txt => "Quiz1 - Question1", :true_false => 0, :weight => 1,
                    :questionnaire_id => 198
    Question.create :txt => "Quiz1 - Question2", :true_false => 0, :weight => 1,
                    :questionnaire_id => 198
    Question.create :txt => "Quiz1 - Question3", :true_false => 0, :weight => 1,
                    :questionnaire_id => 198
    Question.create :txt => "Quiz1 - Question4", :true_false => 0, :weight => 1,
                    :questionnaire_id => 198
    Question.create :txt => "Quiz1 - Question5", :true_false => 0, :weight => 1,
                    :questionnaire_id => 198
    Question.create :txt => "Quiz2 - Question1", :true_false => 0, :weight => 1,
                    :questionnaire_id => 200
    Question.create :txt => "Quiz2 - Question2", :true_false => 0, :weight => 1,
                    :questionnaire_id => 200
    Question.create :txt => "Quiz2 - Question3", :true_false => 0, :weight => 1,
                    :questionnaire_id => 200
    Question.create :txt => "Quiz2 - Question4", :true_false => 0, :weight => 1,
                    :questionnaire_id => 200
  end

  def self.down
  end
end
