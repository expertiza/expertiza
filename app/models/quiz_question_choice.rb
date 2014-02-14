class QuizQuestionChoice < ActiveRecord::Base
  belongs_to :question, :dependent => :destroy
end
