class RemoveAdditionalFeedback < ActiveRecord::Migration
  # delete any duplicate feedback objects. Keep only the most current
  def self.up     
    entries = ActiveRecord::Base.connection.select_all("SELECT * FROM review_feedbacks f1 WHERE review_id IN (SELECT review_id FROM `review_feedbacks` GROUP BY review_id HAVING count(*) > 1)")
         
    max_update = nil
    max_id = nil
    current_review = nil
    entries.each{
      | entry |
      if entry['review_id'].to_i != current_review
        current_review = entry['review_id'].to_i
        if entry['updated_at']
          max_update = entry['updated_at']
        end        
        
      elsif (entry['updated_at'] and entry['updated_at'] > max_update and max_id > 0) or
            (entry.id > max_id and max_id > 0)
        execute "delete from review_feedbacks where id = #{max_id}"                                        
      end
      max_update = entry['updated_at']
      max_id = entry['id'].to_i
    }     
  end

  def self.down
  end
end
