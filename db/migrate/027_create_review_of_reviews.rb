class CreateReviewOfReviews < ActiveRecord::Migration
  def self.up
  create_table "metareviews", :force => true do |t|
    t.column "reviewed_at", :datetime
    t.column "metareview_mapping_id", :integer
    t.column "review_num_for_author", :integer
    t.column "review_num_for_reviewer", :integer
  end

  add_index "metareviews", ["metareview_mapping_id"], :name => "fk_metareview_metareview_mappings"

  execute "alter table metareviews
             add constraint fk_metareview_metareview_mappings
             foreign key (metareview_mapping_id) references metareview_mappings(id)"
             
  end

  def self.down
    drop_table "metareviews"
  end
end
