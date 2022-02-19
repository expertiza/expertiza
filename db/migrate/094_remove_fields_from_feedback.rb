class RemoveFieldsFromFeedback < ActiveRecord::Migration[4.2]
  def self.up
    begin
      remove_column :review_feedbacks, :feedback_at
    rescue StandardError
    end

    begin
      rename_column :review_feedbacks, :additional_comments, :additional_comment
    rescue StandardError
    end

    begin
      execute 'update `review_feedbacks` set `additional_comment` = `txt` where `txt` IS NOT NULL'
    rescue StandardError
    end

    begin
      remove_column :review_feedbacks, :txt
    rescue StandardError
    end
  end

  def self.down; end
end
