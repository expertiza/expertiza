class QuestionAdvice < ActiveRecord::Base
  belongs_to :question

  attr_accessible
end
