<<<<<<< HEAD
class UpdateReviewMappings < ActiveRecord::Migration[4.2]
    def self.up
    add_column "review_mappings","round",:integer
    
    execute "update review_mappings set round = -1"
    
  end
=======
class UpdateReviewMappings < ActiveRecord::Migration
  def self.up
    add_column 'review_mappings', 'round', :integer

    execute 'update review_mappings set round = -1'
end
>>>>>>> 81deb907b3ee7c4805798510a756fd42a7f8cc1b

  def self.down
    remove_column 'review_mappings', 'round'
  end
end
