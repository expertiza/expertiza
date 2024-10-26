class Questionnaire < ApplicationRecord
  # for doc on why we do it this way,
  # see http://blog.hasmanythrough.com/2007/1/15/basic-rails-association-cardinality
  has_many :items, dependent: :destroy # the collection of items associated with this Questionnaire
  belongs_to :instructor # the creator of this itemnaire
  has_many :assignment_itemnaires, dependent: :destroy
  has_many :assignments, through: :assignment_itemnaires
  has_one :itemnaire_node, foreign_key: 'node_object_id', dependent: :destroy, inverse_of: :itemnaire

  validate :validate_itemnaire
  validates :name, presence: true
  validates :max_item_score, :min_item_score, numericality: true

  DEFAULT_MIN_QUESTION_SCORE = 0  # The lowest score that a reviewer can assign to any itemnaire item
  DEFAULT_MAX_QUESTION_SCORE = 5  # The highest score that a reviewer can assign to any itemnaire item
  DEFAULT_QUESTIONNAIRE_URL = 'http://www.courses.ncsu.edu/csc517'.freeze
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
                         'Bookmark RatingQuestionnaire',
                         'BookmarkRatingQuestionnaire',
                         'QuizQuestionnaire'].freeze
  has_paper_trail

  def get_weighted_score(assignment, scores)
    # create symbol for "varying rubrics" feature -Yang
    round = AssignmentQuestionnaire.find_by(assignment_id: assignment.id, itemnaire_id: id).used_in_round
    itemnaire_symbol = if round.nil?
                             symbol
                           else
                             (symbol.to_s + round.to_s).to_sym
                           end
    compute_weighted_score(itemnaire_symbol, assignment, scores)
  end

  def compute_weighted_score(symbol, assignment, scores)
    aq = assignment_itemnaires.find_by(assignment_id: assignment.id)
    if scores[symbol][:scores][:avg].nil?
      0
    else
      scores[symbol][:scores][:avg] * aq.itemnaire_weight / 100.0
    end
  end

  # Does this itemnaire contain true/false items?
  def true_false_items?
    items.each { |item| return true if item.type == 'Checkbox' }
    false
  end

  def delete
    assignments.each do |assignment|
      raise "The assignment #{assignment.name} uses this itemnaire.
            Do you want to <A href='../assignment/delete/#{assignment.id}'>delete</A> the assignment?"
    end

    items.each(&:delete)

    node = QuestionnaireNode.find_by(node_object_id: id)
    node.destroy if node

    destroy
  end

  def max_possible_score
    results = Questionnaire.joins('INNER JOIN items ON items.itemnaire_id = itemnaires.id')
                           .select('SUM(items.weight) * itemnaires.max_item_score as max_score')
                           .where('itemnaires.id = ?', id)
    results[0].max_score
  end

  # clones the contents of a itemnaire, including the items and associated advice
  def self.copy_itemnaire_details(params, instructor_id)
    orig_itemnaire = Questionnaire.find(params[:id])
    items = Question.where(itemnaire_id: params[:id])
    itemnaire = orig_itemnaire.dup
    itemnaire.instructor_id = instructor_id
    itemnaire.name = 'Copy of ' + orig_itemnaire.name
    itemnaire.created_at = Time.zone.now
    itemnaire.save!
    items.each do |item|
      new_item = item.dup
      new_item.itemnaire_id = itemnaire.id
      new_item.size = '50,3' if (new_item.is_a?(Criterion) || new_item.is_a?(TextResponse)) && new_item.size.nil?
      new_item.save!
      advices = QuestionAdvice.where(item_id: item.id)
      next if advices.empty?

      advices.each do |advice|
        new_advice = advice.dup
        new_advice.item_id = new_item.id
        new_advice.save!
      end
    end
    itemnaire
  end

  # validate the entries for this itemnaire
  def validate_itemnaire
    errors.add(:max_item_score, 'The maximum item score must be a positive integer.') if max_item_score < 1
    errors.add(:min_item_score, 'The minimum item score must be a positive integer.') if min_item_score < 0
    errors.add(:min_item_score, 'The minimum item score must be less than the maximum.') if min_item_score >= max_item_score

    results = Questionnaire.where('id <> ? and name = ? and instructor_id = ?', id, name, instructor_id)
    errors.add(:name, 'Questionnaire names must be unique.') if results.present?
  end
end
