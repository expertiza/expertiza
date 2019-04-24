class AddSuggestionSentimentScoreToResponses < ActiveRecord::Migration
  def change
    add_column :responses, :suggestion_sentiment_score, :float
  end
end
