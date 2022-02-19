<<<<<<< HEAD
class UpdateReviewFeedbacks < ActiveRecord::Migration[4.2]
  def self.up    
=======
class UpdateReviewFeedbacks < ActiveRecord::Migration
  def self.up
>>>>>>> 81deb907b3ee7c4805798510a756fd42a7f8cc1b
    rename_column :review_feedbacks, :user_id, :author_id
    rename_column :review_feedbacks, :txt, :additional_comment
  end

  def self.down
    rename_column :review_feedbacks, :author_id, :user_id
    rename_column :review_feedbacks, :additional_comment, :txt
  end
end
