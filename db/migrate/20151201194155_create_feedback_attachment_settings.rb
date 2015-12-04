class CreateFeedbackAttachmentSettings < ActiveRecord::Migration
  def change
    create_table :feedback_attachment_settings do |t|
      t.string :file_type

      t.timestamps null: false
    end
  end
end
