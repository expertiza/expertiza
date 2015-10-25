class CreateReviewOfReviews < ActiveRecord::Migration
  def self.up
  create_table "review_of_reviews", :force => true do |t|
    t.column "reviewed_at", :datetime
    t.column "review_of_review_mapping_id", :integer
    t.column "review_num_for_author", :integer
    t.column "review_num_for_reviewer", :integer
  end



  add_index "review_of_reviews", ["review_of_review_mapping_id"], :name => "fk_review_of_review_review_of_review_mappings"

  execute "alter table review_of_reviews
             add constraint fk_review_of_review_review_of_review_mappings
             foreign key (review_of_review_mapping_id) references review_of_review_mappings(id)"
             
  end

  def self.down
    drop_table "review_of_reviews"
  end
end
