class Question < ApplicationRecord
  belongs_to :questionnaire # each question belongs to a specific questionnaire
  belongs_to :review_of_review_score # ditto
  has_many :question_advices, dependent: :destroy # for each question, there is separate advice about each possible score
  has_many :signup_choices # ?? this may reference signup type questionnaires
  has_many :answers, dependent: :destroy

  validates :seq, presence: true # user must define sequence for a question
  validates :seq, numericality: true # sequence must be numeric
  validates :txt, length: { minimum: 0, allow_nil: false, message: "can't be nil" } # user must define text content for a question
  validates :type, presence: true # user must define type for a question
  validates :break_before, presence: true

  has_paper_trail

  # Class variables - used in questionnaires_controller.rb to set the parameters for a question.
  MAX_LABEL = 'Strongly agree'.freeze
  MIN_LABEL = 'Strongly disagree'.freeze
  SIZES = { 'Criterion' => '50, 3', 'Cake' => '50, 3', 'TextArea' => '60, 5', 'TextField' => '30' }.freeze
  ALTERNATIVES = { 'Dropdown' => '0|1|2|3|4|5' }.freeze
  attr_accessor :checked

  # Custom delete method that also removes associated QuestionAdvice records
  def delete
    QuestionAdvice.where(question_id: id).find_each(&:destroy)
    destroy
  end

  # Returns a user-friendly question type based on stored DB values for quiz questions
  def get_formatted_question_type
    type = self.type
    case type
    when 'TrueFalse' then 'True/False'
    when 'MultipleChoiceCheckbox' then 'Multiple Choice - Checked'
    when 'MultipleChoiceRadio' then 'Multiple Choice - Radio'
    else ''
    end
  end

  # Placeholder methods, override in derived classes if required.
  # this method decide what to display if an instructor (etc.) is creating or editing a questionnaire
  def edit
  end
  # this method decide what to display if an instructor (etc.) is viewing a questionnaire
  def view_question_text
  end
  # this method decide what to display if a student is filling out a questionnaire
  def view_completed_question
  end
  # this method decide what to display if a student is viewing a filled-out questionnaire
  def complete
  end
  def self.compute_question_score
  end


  # This method returns questions (question_ids) in one assignment where the comments field is meaningful (ScoredQuestion and TextArea types)
  def self.get_all_questions_with_comments_available(assignment_id)
    question_ids = []
    questionnaires = Assignment.find(assignment_id).questionnaires.select { |questionnaire| questionnaire.type == 'ReviewQuestionnaire' }
    questionnaires.each do |questionnaire|
      questions = questionnaire.questions.select { |question| question.is_a?(ScoredQuestion) || question.instance_of?(TextArea) }
      questions.each { |question| question_ids << question.id }
    end
    question_ids
  end

  # Imports question data from a row into the specified questionnaire, or creates a new question if it doesn't exist
  def self.import(row, _row_header, _session, q_id = nil)
    raise ArgumentError, 'Not enough items: expect 3 columns: your login name, your full name' \
    '(first and last name, not separated with the delimiter), and your email.' unless row.length == 5

    questionnaire = Questionnaire.find_by(id: q_id)
    raise ArgumentError, 'Questionnaire Not Found' if questionnaire.nil?

    questions = questionnaire.questions
    qid = 0
    questions.each do |q|
      if q.seq == row[2].strip.to_f
        qid = q.id
        break
      end
    end

    if qid > 0
      question = Question.find_by(id: qid)
      attributes = {}
      attributes['txt'] = row[0].strip
      attributes['type'] = row[1].strip
      attributes['seq'] = row[2].strip.to_f
      attributes['size'] = row[3].strip
      attributes['break_before'] = row[4].strip
      question.questionnaire_id = q_id
      question.update(attributes)
    else
      attributes = {}
      attributes['txt'] = row[0].strip
      attributes['type'] = row[1].strip
      attributes['seq'] = row[2].strip.to_f
      attributes['size'] = row[3].strip
      question = Question.new(attributes)
      question.questionnaire_id = q_id
      question.save
    end
  end

  # Defines the fields to be included in the export of questions
  def self.export_fields(_options)
    fields = ['Seq', 'Question', 'Type', 'Weight', 'text area size', 'max_label', 'min_label']
    fields
  end

  # Exports question data to CSV for a given questionnaire (by parent_id)
  def self.export(csv, parent_id, _options)
    questionnaire = Questionnaire.find(parent_id)
    questionnaire.questions.each do |question|
      csv << [question.seq, question.txt, question.type,
              question.weight, question.size, question.max_label,
              question.min_label]
    end
  end
end