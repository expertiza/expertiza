class Question < ApplicationRecord
  belongs_to :itemnaire # each item belongs to a specific itemnaire
  belongs_to :review_of_review_score # ditto
  has_many :item_advices, dependent: :destroy # for each item, there is separate advice about each possible score
  has_many :signup_choices # ?? this may reference signup type itemnaires
  has_many :answers, dependent: :destroy

  validates :seq, presence: true # user must define sequence for a item
  validates :seq, numericality: true # sequence must be numeric
  validates :txt, length: { minimum: 0, allow_nil: false, message: "can't be nil" } # user must define text content for a item
  validates :type, presence: true # user must define type for a item
  validates :break_before, presence: true

  has_paper_trail

  # Class variables - used itemnaires_controller.rb to set the parameters for a item.
  MAX_LABEL = 'Strongly agree'.freeze
  MIN_LABEL = 'Strongly disagree'.freeze
  SIZES = { 'Criterion' => '50, 3', 'Cake' => '50, 3', 'TextArea' => '60, 5', 'TextField' => '30' }.freeze
  ALTERNATIVES = { 'Dropdown' => '0|1|2|3|4|5' }.freeze
  attr_accessor :checked

  def delete
    QuestionAdvice.where(item_id: id).find_each(&:destroy)
    destroy
  end

  # for quiz items, we store 'TrueFalse', 'MultipleChoiceCheckbox', 'MultipleChoiceRadio' in the DB, and the full names are returned below
  def get_formatted_item_type
    type = self.type
    statement = ''
    if type == 'TrueFalse'
      statement = 'True/False'
    elsif type == 'MultipleChoiceCheckbox'
      statement = 'Multiple Choice - Checked'
    elsif type == 'MultipleChoiceRadio'
      statement = 'Multiple Choice - Radio'
    end
    statement
  end

  # Placeholder methods, override in derived classes if required.
  # this method decide what to display if an instructor (etc.) is creating or editing a itemnaire
  def edit
    nil
  end

  # this method decide what to display if an instructor (etc.) is viewing a itemnaire
  def view_item_text
    nil
  end

  # this method decide what to display if a student is filling out a itemnaire
  def view_completed_item
    nil
  end

  # this method decide what to display if a student is viewing a filled-out itemnaire
  def complete
    nil
  end

  def self.compute_item_score
    0
  end

  # this method return items (item_ids) in one assignment whose comments field are meaningful (ScoredQuestion and TextArea)
  def self.get_all_items_with_comments_available(assignment_id)
    item_ids = []
    itemnaires = Assignment.find(assignment_id).itemnaires.select { |itemnaire| itemnaire.type == 'ReviewQuestionnaire' }
    itemnaires.each do |itemnaire|
      items = itemnaire.items.select { |item| item.is_a?(ScoredQuestion) || item.instance_of?(TextArea) }
      items.each { |item| item_ids << item.id }
    end
    item_ids
  end

  def self.import(row, _row_header, _session, q_id = nil)
    if row.length != 5
      raise ArgumentError,  'Not enough items: expect 3 columns: your login name, your full name' \
                            '(first and last name, not separated with the delimiter), and your email.'
    end
    # itemnaire = Questionnaire.find_by_id(_id)
    itemnaire = Questionnaire.find_by(id: q_id)
    raise ArgumentError, 'Questionnaire Not Found' if itemnaire.nil?

    items = itemnaire.items
    qid = 0
    items.each do |q|
      if q.seq == row[2].strip.to_f
        qid = q.id
        break
      end
    end

    if qid > 0
      # item = Question.find_by_id(qid)
      item = Question.find_by(id: qid)
      attributes = {}
      attributes['txt'] = row[0].strip
      attributes['type'] = row[1].strip
      attributes['seq'] = row[2].strip.to_f
      attributes['size'] = row[3].strip
      attributes['break_before'] = row[4].strip
      item.itemnaire_id = q_id
      item.update(attributes)
    else
      attributes = {}
      attributes['txt'] = row[0].strip
      attributes['type'] = row[1].strip
      attributes['seq'] = row[2].strip.to_f
      attributes['size'] = row[3].strip
      # attributes["break_before"] = row[4].strip
      item = Question.new(attributes)
      item.itemnaire_id = q_id
      item.save
    end
  end

  def self.export_fields(_options)
    fields = ['Seq', 'Question', 'Type', 'Weight', 'text area size', 'max_label', 'min_label']
    fields
  end

  def self.export(csv, parent_id, _options)
    itemnaire = Questionnaire.find(parent_id)
    itemnaire.items.each do |item|
      csv << [item.seq, item.txt, item.type,
              item.weight, item.size, item.max_label,
              item.min_label]
    end
  end
end
