class ChangeSeqFieldInQuestionsTableFromFloatToDecimal < ActiveRecord::Migration
  def self.up
  	change_column :questions, :seq, :decimal, precision: 6, scale: 2
  end

  def self.down
  	change_column :questions, :seq, :float
  end
end
