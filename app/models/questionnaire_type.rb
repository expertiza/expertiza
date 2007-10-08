class QuestionnaireType < ActiveRecord::Base
  validates_presence_of :name
  has_many :rubrics
end
