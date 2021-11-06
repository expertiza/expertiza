class AddMinMaxLableToQuestions < ActiveRecord::Migration
  def self.up
    add_column :questions, :max_label, :string
    add_column :questions, :min_label, :string
  end
end
