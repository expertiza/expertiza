class RemoveFieldsFromFeedback < ActiveRecord::Migration
  def self.up
    begin
      remove_column :review_feedbacks, :user_id
    rescue
    end
  
    begin
      remove_column :review_feedbacks, :feedback_at
    rescue
    end
    
    ReviewFeedback.find(:all).each{
      |feedback|
      if feedback.txt != nil
        feedback.additional_comment = feedback.txt
        feedback.save
      end
    }
    
    begin
      remove_column :review_feedbacks, :txt
    rescue
    end
  end

  def self.down
  end
end
