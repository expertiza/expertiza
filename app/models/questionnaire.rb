class Questionnaire < ActiveRecord::Base
  validate :validate_questionnaire

  def get_weighted_score(assignment, scores)
    # create symbol for "varying rubrics" feature -Yang
    round = AssignmentQuestionnaire.find_by_assignment_id_and_questionnaire_id(assignment.id, self.id).used_in_round
    questionnaire_symbol = if !round.nil?
                             (self.symbol.to_s + round.to_s).to_sym
                           else
                             self.symbol
                           end
    compute_weighted_score(questionnaire_symbol, assignment, scores)
  end

  # for doc on why we do it this way,
  # see http://blog.hasmanythrough.com/2007/1/15/basic-rails-association-cardinality
  has_many :questions, dependent: :destroy # the collection of questions associated with this Questionnaire
  belongs_to :instructor, class_name: "User", foreign_key: "instructor_id" # the creator of this questionnaire
  has_many :assignment_questionnaires, class_name: 'AssignmentQuestionnaire', foreign_key: 'questionnaire_id', dependent: :destroy
  has_many :assignments, through: :assignment_questionnaires
  has_one :questionnaire_node, foreign_key: :node_object_id, dependent: :destroy

  validates_presence_of :name
  validates_numericality_of :max_question_score
  validates_numericality_of :min_question_score

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
                         'Global SurveyQuestionnaire',
                         'GlobalSurveyQuestionnaire',
                         'Course EvaluationQuestionnaire',
                         'CourseEvaluationQuestionnaire',
                         'BookmarkratingQuestionnaire',
                         'QuizQuestionnaire'
                        ].freeze # zhewei: for some historical reasons, some question types have white space, others are not
                                 # need fix them in the future.
  has_paper_trail

  def compute_weighted_score(symbol, assignment, scores)
    aq = self.assignment_questionnaires.find_by_assignment_id(assignment.id)
    if !scores[symbol][:scores][:avg].nil?
      scores[symbol][:scores][:avg] * aq.questionnaire_weight / 100.0
    else
      0
    end
  end

  # Does this questionnaire contain true/false questions?
  def true_false_questions?
    for question in questions
      return true if question.type == "Checkbox"
    end

    false
  end

  def delete
    self.assignments.each do |assignment|
      raise "The assignment #{assignment.name} uses this questionnaire. Do you want to <A href='../assignment/delete/#{assignment.id}'>delete</A> the assignment?"
    end

    self.questions.each &:delete

    node = QuestionnaireNode.find_by_node_object_id(self.id)
    node.destroy if node

    self.destroy
  end

  def max_possible_score
    results = Questionnaire.find_by_sql("SELECT (SUM(q.weight)*rs.max_question_score) as max_score FROM  questions q, questionnaires rs WHERE q.questionnaire_id = rs.id AND rs.id = #{self.id}")
    results[0].max_score
  end

  # validate the entries for this questionnaire
  def validate_questionnaire
    if max_question_score < 1
      errors.add(:max_question_score, "The maximum question score must be a positive integer.")
    end
    if min_question_score >= max_question_score
      errors.add(:min_question_score, "The minimum question score must be less than the maximum")
    end

    results = Questionnaire.where(["id <> ? and name = ? and instructor_id = ?", id, name, instructor_id])
    errors.add(:name, "Questionnaire names must be unique.") if !results.nil? and !results.empty?
  end
end
