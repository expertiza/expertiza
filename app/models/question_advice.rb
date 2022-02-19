class QuestionAdvice < ApplicationRecord
  # attr_accessible :score, :advice
  belongs_to :question

  # This method returns an array of fields present in question advice model
  def self.export_fields(_options)
    fields = []
    QuestionAdvice.columns.each do |column|
      fields.push(column.name)
    end
    fields
  end

  # This method adds the question advice data to CSV for the respective questionnaire
  def self.export(csv, parent_id, _options)
    questionnaire = Questionnaire.find(parent_id)
    questions = questionnaire.questions
    questions.each do |question|
      question_advices = QuestionAdvice.where('question_id = ?', question.id)
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
