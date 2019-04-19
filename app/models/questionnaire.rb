class Questionnaire < ActiveRecord::Base
  # for doc on why we do it this way,
  # see http://blog.hasmanythrough.com/2007/1/15/basic-rails-association-cardinality
  has_many :questions, dependent: :destroy # the collection of questions associated with this Questionnaire
  belongs_to :instructor # the creator of this questionnaire
  has_many :assignment_questionnaires, dependent: :destroy
  has_many :assignments, through: :assignment_questionnaires
  has_one :questionnaire_node, foreign_key: 'node_object_id', dependent: :destroy

  validate :validate_questionnaire
  validates :name, presence: true
  validates :max_question_score, :min_question_score, numericality: true

  DEFAULT_MIN_QUESTION_SCORE = 0  # The lowest score that a reviewer can assign to any questionnaire question
  DEFAULT_MAX_QUESTION_SCORE = 5  # The highest score that a reviewer can assign to any questionnaire question
  DEFAULT_QUESTIONNAIRE_URL = "http://www.courses.ncsu.edu/csc517".freeze
  QUESTIONNAIRE_TYPES = ['ReviewQuestionnaire',	
                         'MetareviewQuestionnaire',	
                         'Author FeedbackQuestionnaire',	
                         'AuthorFeedbackQuestionnaire',	
                         'Teammate ReviewQuestionnaire',	
                         'TeammateReviewQuestionnaire',	
                         'SurveyQuestionnaire',	
                         'AssignmentSurveyQuestionnaire',	
                         'Assignment SurveyQuestionnaire',	
                         'Global SurveyQuestionnaire',	
                         'GlobalSurveyQuestionnaire',	
                         'Course SurveyQuestionnaire',	
                         'CourseSurveyQuestionnaire',	
                         'BookmarkratingQuestionnaire',	
                         'QuizQuestionnaire'].freeze
  has_paper_trail

  def get_weighted_score(assignment, scores)
    # create symbol for "varying rubrics" feature -Yang
    round = AssignmentQuestionnaire.find_by(assignment_id: assignment.id, questionnaire_id: self.id).used_in_round
    questionnaire_symbol = if !round.nil?
                             (self.symbol.to_s + round.to_s).to_sym
                           else
                             self.symbol
                           end
    compute_weighted_score(questionnaire_symbol, assignment, scores)
  end

  def compute_weighted_score(symbol, assignment, scores)
    aq = self.assignment_questionnaires.find_by(assignment_id: assignment.id)
    if !scores[symbol][:scores][:avg].nil?
      scores[symbol][:scores][:avg] * aq.questionnaire_weight / 100.0
    else
      0
    end
  end

  # Does this questionnaire contain true/false questions?
  def true_false_questions?
    questions.each {|question| return true if question.type == "Checkbox" }
    false
  end

  def delete
    self.assignments.each do |assignment|
      raise "The assignment #{assignment.name} uses this questionnaire.
            Do you want to <A href='../assignment/delete/#{assignment.id}'>delete</A> the assignment?"
    end

    self.questions.each(&:delete)

    node = QuestionnaireNode.find_by(node_object_id: self.id)
    node.destroy if node

    self.destroy
  end

  def max_possible_score
    results = Questionnaire.joins('INNER JOIN questions ON questions.questionnaire_id = questionnaires.id')
                           .select('SUM(questions.weight) * questionnaires.max_question_score as max_score')
                           .where('questionnaires.id = ?', self.id)
    results[0].max_score
  end

  # validate the entries for this questionnaire
  def validate_questionnaire
    errors.add(:max_question_score, "The maximum question score must be a positive integer.") if max_question_score < 1
    errors.add(:min_question_score, "The minimum question score must be less than the maximum") if min_question_score >= max_question_score

    results = Questionnaire.where("id <> ? and name = ? and instructor_id = ?", id, name, instructor_id)
    errors.add(:name, "Questionnaire names must be unique.") if results.present?
  end

  # A row_hash here is really just a question that gets added to the questionnaire
  #
  # NOTE: Assuming rows have headers :question, :type, :weight, :param
  # in that specific order. Also need advice with string score
  #
  # TODO: Use test files to ensure this is working
  #
  # At some point, expecting text, type, sequence, size, and break_before
  def self.import(row_hash, id)

    raise ArgumentError, "row_hash cannot be empty when importing Question objects for Questionnaire" if row_hash.empty?
    raise ArgumentError, "id cannot be nil when importing Question objects for Questionnaire" if id.nil?

    questionnaire = Questionnaire.find(id)
    custom_rubric = questionnaire.section == "Custom"

    # Create the question
    q = Question.new
    q.true_false = false

    # TODO: Find out about custom rubrics
    if custom_rubric
      q_type = QuestionType.new
      q_type.parameters = row_hash.delete(:param)
      q_type.q_type = row_hash.delete(:type)
    else
      q.true_false = row_hash.delete(:type) == Question::TRUE_FALSE.downcase
    end

    # TODO: Determine what parameters are required
    q.txt = row_hash.delete(:question)
    q.weight = row_hash.delete(:weight)

    # Add question advice
    row_hash.keys.each do |k|
      # Check score within range
      if k.to_i >= questionnaire.min_question_score && k.to_i <= questionnaire.max_question_score
        a = QuestionAdvice.new(score: k.to_i, advice: row_hash[k])
        q.question_advices << a
      end
    end

    q.save

    if custom_rubric
      q_type.question = q
      q_type.save
    end

    questionnaire.questions << q
  end

  def self.required_import_fields
    {"txt" => "Question text",
     "type" => "Question type",
     "sequence" => "Sequence (for order)",
     "weight" => "Point value"}
  end

  def self.optional_import_fields(id)
    ques = Questionnaire.find(id)
    optional_fields = {"size" => "Size of question",
     "break_before" => "What is this?"}

    if !ques.nil?
      for q in  ques.min_question_score..ques.max_question_score do
        optional_fields["advice_" + q.to_s] = "Advice " + q.to_s
      end
    end
    optional_fields
  end

  def self.import_options
    {}
  end

end
