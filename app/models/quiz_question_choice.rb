class QuizQuestionChoice < ApplicationRecord
  belongs_to :question, dependent: :destroy
end
