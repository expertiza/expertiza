# == Schema Information
#
# Table name: review_comments
#
#  id                      :integer          not null, primary key
#  review_file_id          :integer
#  comment_content         :text
#  reviewer_participant_id :integer
#  file_offset             :integer
#  created_at              :datetime
#  updated_at              :datetime
#  initial_line_number     :integer
#  last_line_number        :integer
#

class ReviewComment < ActiveRecord::Base
  #associate the comment with the file
  belongs_to :review_files, :class_name => 'ReviewFile',
             :foreign_key => 'review_file_id'
end
