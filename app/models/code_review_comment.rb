class CodeReviewComment < ActiveRecord::Base
  belongs_to :code_review_file, :class_name => 'CodeReviewFile', :foreign_key => 'codefileid'
end
