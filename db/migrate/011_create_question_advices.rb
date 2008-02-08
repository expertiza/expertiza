class CreateReviewStrategies < ActiveRecord::Migration
  def self.up
    create_table :review_strategies do |t|
      t.column :name, :string  # the name of the strategy, e.g., "questionnaire", "ranking"
    end
  end

  def self.down
    drop_table :review_strategies
  end
end
