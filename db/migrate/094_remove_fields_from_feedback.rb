class RemoveFieldsFromFeedback < ActiveRecord::Migration
  def self.up
    begin
      remove_column :review_feedbacks, :feedback_at
    rescue
    end
   
    begin 
      rename_column :review_feedbacks, :additional_comments, :additional_comment
    rescue      
    end
    
    execute "update `review_feedbacks` set `additional_comment` = `txt` where `txt` IS NOT NULL"             
    
    begin
      remove_column :review_feedbacks, :txt
    rescue
    end
  end

  def self.down
  end
end
