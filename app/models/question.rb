class Question < ActiveRecord::Base
  belongs_to :questionnaire # each question belongs to a specific questionnaire
  belongs_to :review_score  # each review_score pertains to a particular question
  belongs_to :review_of_review_score  # ditto
  has_many :question_advices, :dependent => :destroy # for each question, there is separate advice about each possible score
  has_many :signup_choices # ?? this may reference signup type questionnaires
  has_one :question_type

  validates_presence_of :txt # user must define text content for a question
  validates_presence_of :weight # user must specify a weight for a question
  validates_numericality_of :weight # the weight must be numeric

  has_paper_trail

  # Class variables
  # Class variables
  NUMERIC = 'Numeric' # Display string for NUMERIC questions
  TRUE_FALSE = 'True/False' # Display string for TRUE_FALSE questions
  GRADING_TYPES = [[NUMERIC,false],[TRUE_FALSE,true]]


  CHECKBOX = 'Checkbox' # Display string for NUMERIC questions
  TEXT_FIELD = 'TextField'
  TEXTAREA = 'TextArea' # Display string for TRUE_FALSE questions
  DROPDOWN = 'DropDown'
  UPLOAD_FILE = 'UploadFile'
  RATING = 'Rating'

  GRADING_TYPES_CUSTOM = [[CHECKBOX,0],[TEXT_FIELD,1],[TEXTAREA,2],[DROPDOWN,3],[UPLOAD_FILE, 4],[RATING, 5]]
  WEIGHTS = [['1',1],['2',2],['3',3],['4',4],['5',5]]
  ANSWERS = [['1',1],['2',2],['3',3],['4',4]] #a hash used while creating a quiz questionnaire
  ANSWERS_TRUE_FALSE = [['1',1],['2',2]]
  ANSWERS_MCQ_CHECKED = [['1',1],['0',2]]
  RATINGS = [['Very Easy',1],['Easy',2],['Medium',3],['Difficult',4],['Very Difficult',5]]
  attr_accessor :checked

  def delete
    QuestionAdvice.where(question_id: self.id).each{|advice| advice.destroy}
    self.destroy
  end

  #merge questions table and question_types table
  #step 1
  def self.add_q_type_in_questions_table
    question_types = QuestionType.all
    question_types.each do |question_type|
      question = Question.find(question_type.question_id)
      question.update_attribute('q_type', question_type.q_type)
    end
  end

  #step 2
  def self.add_size_in_questions_table
    question_types = QuestionType.where("q_type in (?, ?)", 'TextArea', 'TextField')
    question_types.each do |question_type|
      next if question_type.parameters.empty?
      question = Question.find(question_type.question_id)
      size = question_type.parameters.match(/\d*x\d*/).to_s if question_type.q_type == 'TextArea'
      size = question_type.parameters.match(/\d/).to_s if question_type.q_type == 'TextField'
      question.update_attribute('size', size) if size != ""
    end
  end

  #step 3
  def self.add_alternatives_in_questions_table
    question_types = QuestionType.where(q_type: 'DropDown')
    question_types.each do |question_type|
      question = Question.find(question_type.question_id)
      alternatives = question_type.parameters.match(/[a-zA-Z0-9]*\|[a-zA-Z0-9]*/).to_s
      question.update_attribute('alternatives', alternatives)
    end
  end
end
