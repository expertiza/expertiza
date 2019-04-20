class AddSuggestionChancePercentageToResponses < ActiveRecord::Migration
  def change
    add_column :responses, :suggestion_chance_percentage, :integer
    add_column :responses, :suggestion_sentiment_score, :float
    add_column :responses, :overall_tone, :string
  end
end
