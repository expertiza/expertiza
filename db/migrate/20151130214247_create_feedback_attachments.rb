class CreateFeedbackAttachments < ActiveRecord::Migration
  def change
    create_table :feedback_attachments do |t|
      t.string :feedback_id
      t.string :filename
      t.string :content_type
      t.binary :data

      t.timestamps null: false
    end
  end
end
