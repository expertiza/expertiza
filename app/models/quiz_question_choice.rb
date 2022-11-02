# frozen_string_literal: true

class QuizQuestionChoice < ApplicationRecord
  belongs_to :question, dependent: :destroy
end
