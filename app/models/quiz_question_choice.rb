class QuizQuestionChoice < ActiveRecord::Base
  belongs_to :question, :dependent => :destroy
  validates_presence_of :txt, message: 'Please make sure every question has text for all options'
end
