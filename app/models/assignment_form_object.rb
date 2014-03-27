#TODO: Not working yet

class AssignmentFormObject
  include Virtus.model

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :assignment

  attribute :assignment_name, String
  attribute :assignment_course_id, Integer
  attribute :assignment_wiki_type_id, Integer
  attribute :assignment_max_team_size, Integer
  attribute :assignment_instructor, Integer
  attribute :topics_list, Array
  attribute :due_dates_list, Array

  #TODO: I have a feeling these validations are not correct
  validates :assignment, presence: true

  validate :due_dates_list_must_contain_valid_due_dates
  validate :topics_list_must_contain_valid_topics

  #validates :assignment_name, presence: true
  #validates :assignment_name, uniqueness: {scope: :assignment_course_id }
  #validates_uniqueness_of :assignment_name, :scope => :assignment_course_id

  # Forms are never themselves persisted
  def persisted?
    false
  end

  def save
    if valid?
      persist!
      true
    else
      false
    end
  end

  def add_topic(topic)
    #TODO: check if this is right
    topics_list.push(topic)
  end

  def add_due_date(due_date)
    #TODO: check if this is right
    due_dates_list.push(due_date)
  end

  private

  def due_dates_list_must_contain_valid_due_dates
    due_dates_list.each do |due_date|
      if !due_date.valid?
        errors.add(:due_dates_list, "Due date is invalid for assignment with id #{due_date.assignment_id}")
      end
    end
  end

  def topics_list_must_contain_valid_topics
    topics_list.each do |topic|
      if !topic.valid?
        errors.add(:topics_list, "Topic is invalid: #{topic.topic_name}")
      end
    end
    #errors.add(:topics_list, "One of the topics is not valid") unless topics_list.each {|topic| topic.valid?}
  end

  def persist!
    #TODO: make sure this is correct
    #Start a transaction, we only want to create the assignment if we can create EVERYTHING in the assignment
    Assignment.transaction do
      #if we've already made the assignment, don't bother trying to persist that
      if !@assignment
        @assignment = Assignment.create!(:name => assignment_name, :scope => assignment_scope, :course => assignment_course, :instructor => assignment_instructor, :max_team_size => assignment_max_team_size)
        if !@assignment
          raise ActiveRecord::Rollback
        end
      end
      #might need to set the assignment_id in each of these topics and due dates, not sure
      #the interconnections are difficult to figure out from the models
      topics_list.each do |a|
        a.assignment = @assignment
        if a.save
          topics.push(a)
        else
          raise ActiveRecord::Rollback
        end
      end
      #don't need to re-persist these topics, remove them from the "Queue"
      topics_list = []

      due_dates_list.each do |a|
        a.assignment = @assignment
        if a.save
          due_dates.push(a)
        else
          raise ActiveRecord::Rollback
        end
      end
      #same as the topics list
      due_dates_list = []
    end
  end

end