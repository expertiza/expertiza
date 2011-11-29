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
    NUMERIC = 'Numeric' # Display string for NUMERIC questions
    TRUE_FALSE = 'True/False' # Display string for TRUE_FALSE questions
    CHECK_BOX = 'Checkbox' #Display as checkbox
    RADIO_BUTTON = 'Radio' #Display Radio
    
    GRADING_TYPES = [[NUMERIC,false],[TRUE_FALSE,true],[CHECK_BOX,false],[RADIO_BUTTON,false]]
    WEIGHTS = [['1',1],['2',2],['3',3],['4',4],['5',5]]
    
    attr_accessor :checked
    
    def delete      
      QuestionAdvice.find_all_by_question_id(self.id).each{|advice| advice.destroy}
      self.destroy
    end
end
