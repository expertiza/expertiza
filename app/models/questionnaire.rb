
class Questionnaire < ActiveRecord::Base
  validate :validate_questionnaire
  require 'csv'
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

  def to_csvs(abc)
  #  CSV.generate do |csv|
   #   csv << column_names
    #  all.each do |q|
     #   csv << q.questions.attributes.values_at(*column_names)
    #  end
    # end
        questions = abc
        csv_data = CSV.generate do |csv|
          row = ['seq','text','type','weight','size','max_label','min_label']
          csv << row
          for question in questions
            # Each row is formatted as follows
            # Question, question advice (from high score to low), type, weight
            row = []
            row << question.seq
            row << question.txt
            row << question.type
            row << question.weight
            row << question.size || ''
            row << question.max_label
            row << question.min_label

            csv << row

      end
    end
    end


  def self.import(file)

        CSV.parse(file, headers: true) do |row|
        #  row.each do |cell|
        product_hash = row.to_hash # exclude the price field
        product = Question.where(seq: row['seq'])

        if product.count == 1
          product.first.update_attributes(product_hash)
        else
          Question.create!(product_hash)
        end # end if !product.nil?
      end # end CSV.foreach
    end # end self.import(file)
#    CSV::Reader.parse(file) do |row|

=begin
    CSV.foreach(file.path) do |row|

      product_hash = row.to_hash # exclude the price field
      product = Question.where(seq: product_hash["seq"])

      if product.count == 1
        product.first.update_attributes(product_hash)
      else
        Question.create!(product_hash)
      end # end if !product.nil?
=end
=begin
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      product = find_by_id(row["id"]) || new
      product.attributes = row.to_hash.slice(*accessible_attributes)
      product.save!
    end
=end
    end


=begin
  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
      when ".csv" then CSV.new(file.path, :ignore)
      else raise "Unknown file type: #{file.original_filename}"
    end
  end
=end



