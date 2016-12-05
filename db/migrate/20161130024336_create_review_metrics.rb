class CreateReviewMetrics < ActiveRecord::Migration
  def change
    create_table :review_metrics do |t|
      t.column :response_id, :integer
      t.column :volume, :integer
      t.column :suggestion, :boolean,:default => false, null: false
      t.column :problem, :boolean, :default => false, null: false
      t.column :offensive_term, :boolean, :default => false, null: false

      t.timestamps null: false
    end
  end
end
