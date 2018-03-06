class QuizQuestionChoice < ActiveRecord::Base
  belongs_to :question, dependent: :destroy
  attr_accessible :comments, :question_id, :response_id, :answer
end
