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
end
