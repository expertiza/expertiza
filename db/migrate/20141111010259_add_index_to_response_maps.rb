class AddIndexToResponseMaps < ActiveRecord::Migration[4.2]
  def self.up
    # add_index :response_maps, :reviewee_id
    # add_index :response_maps, :reviewer_id
    # add_index :response_maps, :reviewed_object_id

    # add_index :teams_users, :user_id

    # add_index :score_caches, :reviewee_id

    # add_index :responses, :map_id
  end

  def self.down
    # remove_index :responses, :map_id
    # remove_index :score_caches, :reviewee_id
    # remove_index :teams_users, :user_id
    # remove_index :response_maps, :reviewed_object_id
    # remove_index :response_maps, :reviewer_id
    # remove_index :response_maps, :reviewee_id
  end
end
