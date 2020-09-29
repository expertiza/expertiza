class AddConfidenceLevelToAnswerTagsTable < ActiveRecord::Migration
  def change
    add_column :answer_tags, :confidence_level, :decimal, precision: 10, scale: 5
  end
end
