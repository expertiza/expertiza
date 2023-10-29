class AddMinMaxLableToQuestions < ActiveRecord::Migration[4.2]
  def self.up
    add_column :questions, :max_label, :string
    add_column :questions, :min_label, :string
  end
end
