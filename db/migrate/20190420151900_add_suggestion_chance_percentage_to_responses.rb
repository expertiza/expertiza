class AddSuggestionChancePercentageToResponses < ActiveRecord::Migration
  def change
    add_column :responses, :suggestion_chance_percentage, :integer
  end
end
