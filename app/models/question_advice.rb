class QuestionAdvice < ActiveRecord::Base
  belongs_to :question

  def self.export_fields(options)
    fields = []
    QuestionAdvice.columns.each do |column|
      fields.push(column.name)
    end
    fields
  end

  def self.export(csv, _parent_id, options)
    questionnaire = Questionnaire.find_by_id(_parent_id)
    questions = questionnaire.questions
    question_advices = []
    for question in questions
      question_advices = QuestionAdvice.where("question_id = ?",question.id)
      for advice in question_advices
        tcsv = []
        advice.attributes.each_pair do |name,value|
          tcsv.push(value)
        end
        csv << tcsv
      end
    end
  end
end
