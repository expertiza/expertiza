class CodeReviewComment < ActiveRecord::Base
  #associate the comment with the file
  belongs_to :code_review_files, :class_name => 'CodeReviewFile', :foreign_key => 'codefileid'
end
