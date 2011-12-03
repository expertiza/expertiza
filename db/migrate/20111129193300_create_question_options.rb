class CreateQuestionOptions < ActiveRecord::Migration
  def self.up
    create_table :question_options do |t|
      t.column "option_text", :text # the option text
      t.references :questions
      t.timestamps
    end
  end

  def self.down
    drop_table :question_options
  end
end
