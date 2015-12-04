class CreateFeedbackStatuses < ActiveRecord::Migration
  def change
    create_table :feedback_statuses do |t|
      t.string :status

      t.timestamps null: false
    end
  end
end
