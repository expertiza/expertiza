class CreateBookmarkRatingRubrics < ActiveRecord::Migration[4.2]
  def self.up
    if table_exists?(:bookmark_rating_rubrics) == false
      create_table :bookmark_rating_rubrics do |t|
        t.column 'display_text', :string, null: false
        t.column 'minimum_rating', :integer, null: false
        t.column 'maximum_rating', :integer, null: false
        t.timestamps
      end
    end
  end

  def self.down
    drop_table :bookmark_rating_rubrics
  end
end
