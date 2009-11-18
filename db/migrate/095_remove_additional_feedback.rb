class RemoveAdditionalFeedback < ActiveRecord::Migration
  # delete any duplicate feedback objects. Keep only the most current
  def self.up     
    entries = ReviewFeedback.find_by_sql("SELECT * FROM review_feedbacks f1 WHERE review_id IN (SELECT review_id FROM `review_feedbacks` GROUP BY review_id HAVING count(*) > 1)")
    
    max_update = nil
    max_id = nil
    current_review = nil
    entries.each{
      | entry |
      if entry.review_id != current_review
        current_review = entry.review_id
        if entry.updated_at
          max_update = entry.updated_at
        end        
        
      else
        if entry.updated_at and entry.updated_at > max_update and max_id > 0
          prev = ReviewFeedback.find(max_id)
          prev.delete
        elsif entry.id > max_id and max_id > 0
          prev = ReviewFeedback.find(max_id)
          prev.delete                   
        end                
      end
      max_update = entry.updated_at
      max_id = entry.id
    }     
  end

  def self.down
  end
end
