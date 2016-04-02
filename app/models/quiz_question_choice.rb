class QuizQuestionChoice < ActiveRecord::Base
  belongs_to :question, :dependent => :destroy
  validates :txt, presence: true
end
