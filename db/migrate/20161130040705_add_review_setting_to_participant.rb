class AddReviewSettingToParticipant < ActiveRecord::Migration
  def change
    add_column :participants, :reviewsetting, :integer, default: 0
  end
end
