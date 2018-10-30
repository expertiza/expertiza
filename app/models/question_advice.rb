class QuestionAdvice < ActiveRecord::Base
  belongs_to :question

  def self.export_fields(_options)
    fields = []
    QuestionAdvice.columns.each do |column|
      fields.push(column.name)
    end
    fields
  end

  def self.export(csv, parent_id, _options)
    questionnaire = Questionnaire.find(parent_id)
    questions = questionnaire.questions
    questions.each do |question|
      question_advices = QuestionAdvice.where("question_id = ?", question.id)
      question_advices.each do |advice|
        tcsv = []
        advice.attributes.each_pair do |_name, value|
          tcsv.push(value)
        end
        csv << tcsv
      end
    end
  end
end
