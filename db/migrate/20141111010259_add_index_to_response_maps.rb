class AddIndexToResponseMaps < ActiveRecord::Migration
  def change
    add_index :response_maps, :reviewee_id
    add_index :response_maps, :reviewer_id
    add_index :response_maps, :reviewed_object_id

    add_index :teams_users, :user_id

    add_index :score_caches, :reviewee_id

    add_index :responses, :map_id
  end
end
