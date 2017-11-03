class QuestionAdvice < ActiveRecord::Base
  belongs_to :question

  attr_accessible :question_id, :score, :advice
end
