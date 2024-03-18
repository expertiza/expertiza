class CreateQuizQuestionChoices < ActiveRecord::Migration[4.2]
  def self.up
    create_table 'quiz_question_choices', force: true do |t|
      t.column 'question_id', :integer # the question to which this advice belongs
      t.column 'txt', :text # the choice to be given to the user
      t.column 'iscorrect', :boolean, default: false # the correctness of this choice to be given to the user
    end

    #    add_index "question_advices", ["question_id"], :name => "fk_question_question_advices"
  end

  def self.down
    drop_table 'quiz_question_choices'
  end
 end
