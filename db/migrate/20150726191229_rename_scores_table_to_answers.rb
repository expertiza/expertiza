class RenameScoresTableToAnswers < ActiveRecord::Migration
  def self.up
  	rename_table :scores, :answers
  	rename_column :answers, :score, :answer
  end

  def self.down
  	rename_column :answers, :answer, :score
  	rename_table :answers, :scores
  end
end
