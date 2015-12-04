class CreateFeedbacks < ActiveRecord::Migration
  def change
    create_table :feedbacks do |t|
      t.string :user_email
      t.string :title
      t.text :description
      t.string :status

      t.timestamps null: false
    end
  end
end
