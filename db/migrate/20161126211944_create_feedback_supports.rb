class CreateFeedbackSupports < ActiveRecord::Migration
  def change
    create_table :feedback_supports do |t|

      t.timestamps null: false
    end
  end
end
