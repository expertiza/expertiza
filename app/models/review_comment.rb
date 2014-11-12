class ReviewComment < ActiveRecord::Base
  #associate the comment with the file
  belongs_to :review_files, :class_name => 'ReviewFile',
             :foreign_key => 'review_file_id'
end
