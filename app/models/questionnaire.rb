class Questionnaire < ActiveRecord::Base
  # for doc on why we do it this way,
  # see http://blog.hasmanythrough.com/2007/1/15/basic-rails-association-cardinality
  has_many :questions, dependent: :destroy # the collection of questions associated with this Questionnaire
  belongs_to :instructor # the creator of this questionnaire
  has_many :assignment_questionnaires, dependent: :destroy
  has_many :assignments, through: :assignment_questionnaires
  has_one :questionnaire_node, foreign_key: 'node_object_id', dependent: :destroy, inverse_of: :questionnaire

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
                         'Bookmark RatingQuestionnaire',
                         'BookmarkRatingQuestionnaire',
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

  # clones the contents of a questionnaire, including the questions and associated advice
  def self.copy_questionnaire_details(params, instructor_id)
    orig_questionnaire = Questionnaire.find(params[:id])
    questions = Question.where(questionnaire_id: params[:id])
    questionnaire = orig_questionnaire.dup
    questionnaire.instructor_id = instructor_id
    questionnaire.name = 'Copy of ' + orig_questionnaire.name
    questionnaire.created_at = Time.zone.now
    questionnaire.save!
    questions.each do |question|
      new_question = question.dup
      new_question.questionnaire_id = questionnaire.id
      new_question.size = '50,3' if (new_question.is_a? Criterion or new_question.is_a? TextResponse) and new_question.size.nil?
      new_question.save!
      advices = QuestionAdvice.where(question_id: question.id)
      next if advices.empty?
      advices.each do |advice|
        new_advice = advice.dup
        new_advice.question_id = new_question.id
        new_advice.save!
      end
    end
    questionnaire
  end  

  # validate the entries for this questionnaire
  def validate_questionnaire
    errors.add(:max_question_score, "The maximum question score must be a positive integer.") if max_question_score < 1
    errors.add(:min_question_score, "The minimum question score must be a positive integer.") if min_question_score < 0
    errors.add(:min_question_score, "The minimum question score must be less than the maximum.") if min_question_score >= max_question_score

    results = Questionnaire.where("id <> ? and name = ? and instructor_id = ?", id, name, instructor_id)
    errors.add(:name, "Questionnaire names must be unique.") if results.present?
  end

  # delete questions from a questionnaire
  # @param [Object] questionnaire_id
  def delete_questions(params)
    # Deletes any questions that, as a result of the edit, are no longer in the questionnaire
    questions = Question.where("questionnaire_id = ?", self.id)
    @deleted_questions = []
    questions.each do |question|
      should_delete = true
      unless question_params.nil?
        params[:question].each_key do |question_key|
          should_delete = false if question_key.to_s == question.id.to_s
        end
      end

      next unless should_delete
      question.question_advices.each(&:destroy)
      # keep track of the deleted questions
      @deleted_questions.push(question)
      question.destroy
    end
  end

  # save questions that have been added to a questionnaire
  def save_new_questions(params)
    if params[:new_question]
      # The new_question array contains all the new questions
      # that should be saved to the database
      params[:new_question].keys.each_with_index do |question_key, index|
        q = Question.new
        q.txt = params[:new_question][question_key]
        q.questionnaire_id = self.id
        q.type = params[:question_type][question_key][:type]
        q.seq = question_key.to_i
        if self.type == "QuizQuestionnaire"
          # using the weight user enters when creating quiz
          weight_key = "question_#{index + 1}"
          q.weight = params[:question_weights][weight_key.to_sym]
        end
        q.save unless q.txt.strip.empty?
      end
    end
  end

  # Handles questions whose wording changed as a result of the edit
  # @param [Object] questionnaire_id
  def save_questions(params)
    delete_questions params
    save_new_questions params

    if params[:question]
      params[:question].keys.each do |question_key|
        if params[:question][question_key][:txt].strip.empty?
          # question text is empty, delete the question
          Question.delete(question_key)
        else
          # Update existing question.
          question = Question.find(question_key)
          Rails.logger.info(question.errors.messages.inspect) unless question.update_attributes(params[:question][question_key])
        end
      end
    end
  end
end
