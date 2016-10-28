class CreateReviews < ActiveRecord::Migration
  def self.up
  create_table "reviews", :force => true do |t|
    t.column "review_mapping_id", :integer
    t.column "review_num_for_author", :integer
    t.column "review_num_for_reviewer", :integer
    t.column "ignore", :boolean, :default => 0
    t.column "additional_comment", :text
    t.column "updated_at", :datetime
    t.column "created_at", :datetime
  end


  add_index "reviews", ["review_mapping_id"], :name => "fk_review_mappings"

  execute "alter table reviews
             add constraint fk_review_mappings
             foreign key (review_mapping_id) references review_mappings(id)"
             
  end

  def self.down
    drop_table "reviews"
  end
end
