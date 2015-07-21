class QuestionType < ActiveRecord::Base
  belongs_to :question

  validates_presence_of :q_type # user must define type for the custom question

  def self.get_formatted_question_type question_id
    type = QuestionType.find_by_question_id(question_id).q_type

    # for quiz questions, we store 'TF', 'MCC', 'MCR' in the DB, and the full names are returned below
    if type == 'TF'
      return 'True/False'
    elsif type == 'MCC'
      return 'Multiple Choice - Checked'
    elsif type == 'MCR'
      return 'Multiple Choice - Radio'
    end
  end

  def self.find_by_question_id question_id
    question_type_records = QuestionType.where(question_id: question_id)
    if question_type_records.nil?
      nil
    else
      question_type_records.first
    end
  end
end
