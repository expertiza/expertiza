class AddRowsToQuestionnaires < ActiveRecord::Migration
  def self.up
    QuizQuestionnaire.create :name => "Quiz1",:instructor_id => 2987, :private => 1,
                         :min_question_score => 0, :max_question_score => 1,
                         :display_type => "Quiz"

    QuizQuestionnaire.create :name => "Quiz2",:instructor_id => 2987, :private => 1,
                         :min_question_score => 0, :max_question_score => 1,
                         :display_type => "Quiz"

    QuizQuestionnaire.create :name => "Quiz3",:instructor_id => 2987, :private => 1,
                         :min_question_score => 0, :max_question_score => 1,
                         :display_type => "Quiz"

    QuizQuestionnaire.create :name => "Quiz4",:instructor_id => 2987, :private => 1,
                         :min_question_score => 0, :max_question_score => 1,
                         :display_type => "Quiz"

    QuizQuestionnaire.create :name => "Quiz5",:instructor_id => 2987, :private => 1,
                         :min_question_score => 0, :max_question_score => 1,
                         :display_type => "Quiz"
  end

  def self.down
  end
end
