class QuestionType < ActiveRecord::Base
  belongs_to :question

  validates_presence_of :q_type # user must define type for the custom question

  def self.get_formatted_question_type question_id
    type = QuestionType.find_by_question_id(question_id).q_type

    if type == 'TF'
      return 'True/False'
    elsif type == 'Essay'
      return 'Essay'
    elsif type == 'MCC'
      return 'Multiple Choice - Checked'
    elsif type == 'MCR'
      return 'Multiple Choice - Radio'
    end
  end
end
