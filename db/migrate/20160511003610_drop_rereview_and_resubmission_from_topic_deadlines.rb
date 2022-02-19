class DropRereviewAndResubmissionFromTopicDeadlines < ActiveRecord::Migration[4.2]
  def change
    remove_column :topic_deadlines, :resubmission_allowed_id
    remove_column :topic_deadlines, :rereview_allowed_id
  end
end
