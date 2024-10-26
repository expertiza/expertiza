class QuizQuestionChoice < ApplicationRecord
  belongs_to :item, dependent: :destroy
end
