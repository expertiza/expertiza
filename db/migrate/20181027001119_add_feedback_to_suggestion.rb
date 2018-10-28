class AddFeedbackToSuggestion < ActiveRecord::Migration
  def change
    add_column :suggestions, :feedback, :string
  end
end
