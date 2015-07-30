class Question < ActiveRecord::Base
  belongs_to :questionnaire # each question belongs to a specific questionnaire
  belongs_to :review_score  # each review_score pertains to a particular question
  belongs_to :review_of_review_score  # ditto
  has_many :question_advices # for each question, there is separate advice about each possible score
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

  # for quiz questions, we store 'TF', 'MCC', 'MCR' in the DB, and the full names are returned below
  def get_formatted_question_type
    type = self.q_type

    if type == 'TF'
      return 'True/False'
    elsif type == 'MCC'
      return 'Multiple Choice - Checked'
    elsif type == 'MCR'
      return 'Multiple Choice - Radio'
    end
  end

  # Placeholder methods, override in derived classes if required.
  # this method decide what to display if an instructor (etc.) is creating or editing a questionnaire
  def edit
    return nil
  end

  #this method decide what to display if an instructor (etc.) is viewing a questionnaire
  def view_question_text
    return nil
  end

  #this method decide what to display if a student is filling out a questionnaire
  def view_completed_question
    return nil
  end

  #this method decide what to display if a student is viewing a filled-out questionnaire
  def complete
    return nil
  end

  def self.compute_question_score
     return 0
  end

  #multipart rubric rewrite
  #merge questions table and question_types table
  #step 1
  def self.move_true_false_data_into_q_type #true_false: true->Checkbox, false->Criterion
    questions = Question.all
    questions.each do |question|
      if question.true_false == true
        question.update_attribute('q_type', 'Checkbox')
      elsif question.true_false == false
        question.update_attribute('q_type', 'Criterion')
      elsif question.true_false == nil
        question.update_attribute('q_type', 'Checkbox')
      end
    end
  end

  #step 2
  def self.add_q_type_in_questions_table
    question_types = QuestionType.all
    question_types.each do |question_type|
      question = Question.find(question_type.question_id)
      question.update_attribute('q_type', question_type.q_type)
    end
    #q_type: 'rating' -> 'Criterion'
    questions = Question.all
    questions.each do |question|
      question.update_attribute('q_type', 'Criterion') if question.q_type == 'Rating'
    end
  end

  #step 3
  def self.add_size_in_questions_table
    question_types = QuestionType.where("q_type in (?, ?)", 'TextArea', 'TextField')
    question_types.each do |question_type|
      next if question_type.parameters.empty?
      question = Question.find(question_type.question_id)
      size = question_type.parameters.match(/\d*x\d*/).to_s.sub! 'x', ',' if question_type.q_type == 'TextArea'
      size = question_type.parameters.match(/\d/).to_s if question_type.q_type == 'TextField'
      question.update_attribute('size', size) if size != ""
    end
  end

  #step 4
  def self.add_alternatives_in_questions_table
    question_types = QuestionType.where(q_type: 'DropDown')
    question_types.each do |question_type|
      question = Question.find(question_type.question_id)
      alternatives = question_type.parameters.match(/[a-zA-Z0-9]*\|[a-zA-Z0-9]*/).to_s
      question.update_attribute('alternatives', alternatives)
    end
  end

  #step 5
  def self.find_customized_questions
    customed_questions = Array.new
    question_types = QuestionType.all
    question_types.each do |question_type|
      customed_questions << question_type.question_id
    end
    customed_questions
  end

  #step 6
  def self.use_primary_key_as_seq_no
    customed_questions = Question.find_customized_questions
    questions = Question.all
    questions.each do |question|
      question.update_attribute('seq', question.id)
    end
  end

  #step 7
  #Migrate 'answers' table
  #Although there are many criterion question in customed questionnaires,
  #only question_ids in (1923~1938) and (2449~2482) have corresponding records in 'answers' table.
  def self.copy_comments_value_to_score_value_in_every_odd_num_record
    question_ids = [1923, 1925, 1927, 1929, 1931, 1933, 1935, 1937, 2449, 2451, 2453, 2455, 2457, 2459, 
2461, 2463, 2465, 2467, 2469, 2471, 2473, 2475, 2477, 2479, 2481]
    question_ids.each do |question_id|
      answers = Answer.where(question_id: question_id)
      answers.each do |answer|
        answer.update_attributes(answer: answer.comments, comments: Answer.find(answer.id + 1).comments)
      end
    end
  end

  #step 8
  #Now records in 'answers' table, the txt of these corresponding question being 'Comment:' is useless.
  def self.remove_useless_comment_records_from_answers_table
    question_ids = [1924, 1926, 1928, 1930, 1932, 1934, 1936, 1938, 2450, 2452, 2454, 2456, 2458, 2460, 2462, 2464, 2466, 2468, 2470, 2472, 2474, 2476, 2478, 2480, 2482]
    question_ids.each do |question_id|
      Answer.where(question_id: question_id).destroy_all
    end
  end

  #step 9
  #Now records in 'questions' table whose txt is 'Comment:' is useless.
  def self.remove_useless_comment_records_from_questions_table
    #questions = Question.where(["q_type = ? and txt = ?", 'Criterion', 'Comment:'])
    #questions.each do |question|
    #  QuestionAdvice.where(question_id: question.id).destroy_all
    #  QuestionType.where(question_id: question.id).destroy_all
    #end
    Question.where(["q_type = ? and txt = ?", 'Criterion', 'Comment:']).destroy_all
  end

  #step 10
  #Add 'section_header' to questions table
  def self.add_section_header_to_questions_table
    question_types = QuestionType.all
    question_types.each do |question_type|
      txt = question_type.parameters.match(/\A\w*\s*\w*/).to_s
      seq = question_type.question_id - 0.75
      questionnaire_id = Question.find(question_type.question_id).questionnaire_id
      Question.create(txt: txt, weight: 1, questionnaire_id: questionnaire_id, seq: seq, q_type: 'Section_header', break_before: 1)
    end
  end

  #step 11
  #delete unused questionnaires and corresponding questions and question advices
  def self.delete_unused_questionnaires
    unused_questionnaire_ids = [126, 133, 151, 170, 171, 180, 186, 197, 203, 205, 206, 207, 208, 209, 210, 212, 216, 220, 222, 223, 224, 225, 229, 230, 231, 232, 233, 234, 235, 241, 244, 247, 251]
    unused_questionnaire_ids.each do |questionnaire_id|
      questions = Question.where(questionnaire_id: questionnaire_id)
      questions.each do |question|
        QuestionAdvice.where(question_id: question.id).destroy_all
        QuestionType.where(question_id: question.id).destroy_all
      end
      questions.destroy_all
      Questionnaire.find(questionnaire_id).destroy
    end
  end
end
