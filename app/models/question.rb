class Question < ActiveRecord::Base
  belongs_to :questionnaire # each question belongs to a specific questionnaire
  belongs_to :review_score  # each review_score pertains to a particular question
  belongs_to :review_of_review_score # ditto
  has_many :question_advices # for each question, there is separate advice about each possible score
  has_many :signup_choices # ?? this may reference signup type questionnaires
  has_many :answers

  validates_presence_of :seq # user must define sequence for a question
  validates_numericality_of :seq # sequence must be numeric
  validates :txt, length: {minimum: 0, allow_nil: false, message: "can't be nil"} # user must define text content for a question
  validates_presence_of :type # user must define type for a question
  validates_presence_of :break_before

  has_paper_trail

  # Class variables
  NUMERIC = 'Numeric'.freeze # Display string for NUMERIC questions
  TRUE_FALSE = 'True/False'.freeze # Display string for TRUE_FALSE questions
  GRADING_TYPES = [[NUMERIC, false], [TRUE_FALSE, true]].freeze

  CHECKBOX = 'Checkbox'.freeze # Display string for NUMERIC questions
  TEXT_FIELD = 'TextField'.freeze
  TEXTAREA = 'TextArea'.freeze # Display string for TRUE_FALSE questions
  DROPDOWN = 'DropDown'.freeze
  UPLOAD_FILE = 'UploadFile'.freeze
  RATING = 'Rating'.freeze

  GRADING_TYPES_CUSTOM = [[CHECKBOX, 0], [TEXT_FIELD, 1], [TEXTAREA, 2], [DROPDOWN, 3], [UPLOAD_FILE, 4], [RATING, 5]].freeze
  WEIGHTS = [['1', 1], ['2', 2], ['3', 3], ['4', 4], ['5', 5]].freeze
  ANSWERS = [['1', 1], ['2', 2], ['3', 3], ['4', 4]].freeze # a hash used while creating a quiz questionnaire
  ANSWERS_TRUE_FALSE = [['1', 1], ['2', 2]].freeze
  ANSWERS_MCQ_CHECKED = [['1', 1], ['0', 2]].freeze
  RATINGS = [['Very Easy', 1], ['Easy', 2], ['Medium', 3], ['Difficult', 4], ['Very Difficult', 5]].freeze
  attr_accessor :checked

  def delete
    QuestionAdvice.where(question_id: self.id).find_each(&:destroy)
    self.destroy
  end

  # for quiz questions, we store 'TrueFalse', 'ultipleChoiceCheckbox', 'MultipleChoiceRadio' in the DB, and the full names are returned below
  def get_formatted_question_type
    type = self.type

    if type == 'TrueFalse'
      return 'True/False'
    elsif type == 'MultipleChoiceCheckbox'
      return 'Multiple Choice - Checked'
    elsif type == 'MultipleChoiceRadio'
      return 'Multiple Choice - Radio'
    end
  end

  # Placeholder methods, override in derived classes if required.
  # this method decide what to display if an instructor (etc.) is creating or editing a questionnaire
  def edit
    nil
  end

  # this method decide what to display if an instructor (etc.) is viewing a questionnaire
  def view_question_text
    nil
  end

  # this method decide what to display if a student is filling out a questionnaire
  def view_completed_question
    nil
  end

  # this method decide what to display if a student is viewing a filled-out questionnaire
  def complete
    nil
  end

  def self.compute_question_score
    0
  end

  # this method return questions (question_ids) in one assignment whose comments field are meaningful (ScoredQuestion and TextArea)
  def self.get_all_questions_with_comments_available(assignment_id)
    question_ids = []
    questionnaires = Assignment.find(assignment_id).questionnaires.select{|questionnaire| questionnaire.type == 'ReviewQuestionnaire'}
    questionnaires.each do |questionnaire|
      questions = questionnaire.questions.select{|question| question.is_a? ScoredQuestion or question.instance_of? TextArea}
      questions.each{|question| question_ids << question.id }
    end
    question_ids
  end
end
