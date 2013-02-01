class QuestionType < ActiveRecord::Base

    belongs_to :question, :class_name => "Question", :foreign_key => "question_id" #the question the type is for

    validates_presence_of :q_type # user must define type for the custom question
end
