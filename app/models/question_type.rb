class QuestionType < ActiveRecord::Base

    belongs_to :question

    validates_presence_of :q_type # user must define type for the custom question
end
