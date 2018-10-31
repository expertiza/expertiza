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
  # zhewei: for some historical reasons, some question types have white space, others are not
  # need fix them in the future.
  has_paper_trail

  def set_dispay_type(display_type)
      case display_type
      when 'Review'
	display_type = 'Review'
      when 'Metareview'
	display_type = 'Metareview'
      when 'AuthorFeedback'
        display_type = 'Author%Feedback'
      when 'CourseSurvey'
        display_type = 'Course%Survey'
      when 'TeammateReview'
        display_type = 'Teammate%Review'
      when 'GlobalSurvey'
        display_type = 'Global%Survey'
      when 'AssignmentSurvey'
        display_type = 'Assignment%Survey'
      when 'Bookmarkrating'
	display_type = 'Bookmarkrating'
      end
  end

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

    # clones the contents of a questionnaire, including the questions and associated advice
  def copy_questionnaire_details(questions, orig_questionnaire, id)
    self.instructor_id = self.assign_instructor_id()
    self.name = 'Copy of ' + orig_questionnaire.name
    begin
      self.created_at = Time.now
      self.save!
      questions.each do |question|
        new_question = question.dup
        new_question.questionnaire_id = id
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

      pFolder = TreeFolder.find_by(name: question.set_display_type(display_type))
      parent = FolderNode.find_by(node_object_id: pFolder.id)
      QuestionnaireNode.find_or_create_by(parent_id: parent.id, node_object_id: id)
      undo_link("Copy of questionnaire #{orig_questionnaire.name} has been created successfully.")
      redirect_to controller: 'questionnaires', action: 'view', id: @questionnaire.id
    rescue StandardError
      flash[:error] = 'The questionnaire was not able to be copied. Please check the original course for missing information.' + $ERROR_INFO
      redirect_to action: 'list', controller: 'tree_display'
    end
  end
  
  def export
    @questionnaire = Questionnaire.find(params[:id])

    csv_data = QuestionnaireHelper.create_questionnaire_csv @questionnaire, session[:user].name

    send_data csv_data,
              type: 'text/csv; charset=iso-8859-1; header=present',
              disposition: "attachment; filename=questionnaires.csv"
  end

  def import
    @questionnaire = Questionnaire.find(params[:id])

    file = params['csv']

    @questionnaire.questions << QuestionnaireHelper.get_questions_from_csv(@questionnaire, file)
  end

  def assign_instructor_id
    # if the user to copy the questionnaire is a TA, the instructor should be the owner instead of the TA
    if session[:user].role.name != "Teaching Assistant"
      session[:user].id
    else # for TA we need to get his instructor id and by default add it to his course for which he is the TA
      Ta.get_my_instructor(session[:user].id)
    end
  end

end
