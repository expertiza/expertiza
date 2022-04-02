class UpdateCache < ActiveRecord::Migration[4.2]
  def self.up
    remove_column :score_caches, :assignment_id
    rename_column :score_caches, :object_id, :reviewee_id
    remove_column :score_caches, :course_id
    end

  def self.down
    add_column :score_caches, :assignment_id, :integer
    rename_column :score_caches, :reviewee_id, :object_id
    add_column :score_caches, :course_id, :integer
  end
end
