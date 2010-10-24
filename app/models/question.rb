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
  
  GRADING_TYPES = [[NUMERIC,false],[TRUE_FALSE,true]]
  WEIGHTS = [['1',1],['2',2],['3',3],['4',4],['5',5]]
  
  attr_accessor :checked
  
  def delete      
    QuestionAdvice.find_all_by_question_id(self.id).each{|advice| advice.destroy}
    self.destroy
  end
  
  def parse
    q_and_a = txt.split(/\{|\}/).collect do |x| x.strip end
    answers = q_and_a[1]
    offset = answers.index(/=|~/)
    output = {:question => q_and_a[0], :answers => [], :correct => []}
    count = 0
    while offset
      next_offset = answers.index(/=|~/, offset + 1)
      puts "#{answers[offset]}"
      if answers[offset...offset+1] =~ /=/
        puts 'Correct!'
        output[:correct] << count
      end
      if next_offset
        terminus = next_offset
      else
        terminus = answers.length
      end    
      output[:answers] << answers[offset+1...terminus].strip
      offset = next_offset
      count = count + 1
    end
    output
  end
end
