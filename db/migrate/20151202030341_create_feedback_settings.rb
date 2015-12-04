class CreateFeedbackSettings < ActiveRecord::Migration
  def change
    create_table :feedback_settings do |t|
      t.string :support_mail
      t.integer :max_attachments
      t.integer :max_attachment_size
      t.integer :wrong_retries
      t.integer :wait_duration
      t.integer :wait_duration_increment
      t.string :support_team

      t.timestamps null: false
    end
  end
end
