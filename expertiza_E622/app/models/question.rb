class Question < ActiveRecord::Base
    belongs_to :questionnaire # each question belongs to a specific questionnaire
    belongs_to :review_score  # each review_score pertains to a particular question
    belongs_to :review_of_review_score  # ditto
    has_many :question_advices, :order => 'score' # for each question, there is separate advice about each possible score
    has_many :signup_choices # ?? this may reference signup type questionnaires
    
    validates_presence_of :txt # user must define text content for a question
    validates_presence_of :weight # user must specify a weight for a question
    validates_numericality_of :weight # the weight must be numeric
    
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
    
    attr_accessor :checked
    
    def delete      
      QuestionAdvice.find_all_by_question_id(self.id).each{|advice| advice.destroy}
      self.destroy
    end
end
