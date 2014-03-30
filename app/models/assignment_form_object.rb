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
  validate :assignment_must_be_valid
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

  def assignment_must_be_valid
    if !@assignment.valid?
      errors.add(:assignment, "Assignment is not valid")
    end
  end

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

  def set_up_assignment_review
    set_up_defaults

    submissions = @assignment.find_due_dates('submission') + @assignment.find_due_dates('resubmission')
    reviews = @assignment.find_due_dates('review') + @assignment.find_due_dates('rereview')
    @assignment.rounds_of_reviews = [@assignment.rounds_of_reviews, submissions.count, reviews.count].max

    if @assignment.directory_path.try :empty?
      @assignment.directory_path = nil
    end
  end

  def set_up_defaults
    if @assignment.require_signup.nil?
      @assignment.require_signup = false
    end
    if @assignment.wiki_type.nil?
      @assignment.wiki_type = WikiType.find_by_name('No')
    end
    if @assignment.staggered_deadline.nil?
      @assignment.staggered_deadline = false
      @assignment.days_between_submissions = 0
    end
    if @assignment.availability_flag.nil?
      @assignment.availability_flag = false
    end
    if @assignment.microtask.nil?
      @assignment.microtask = false
    end
    if @assignment.is_coding_assignment .nil?
      @assignment.is_coding_assignment  = false
    end
    if @assignment.reviews_visible_to_all.nil?
      @assignment.reviews_visible_to_all = false
    end
    if @assignment.review_assignment_strategy.nil?
      @assignment.review_assignment_strategy = ''
    end
    if @assignment.require_quiz.nil?
      @assignment.require_quiz =  false
      @assignment.num_quiz_questions =  0
    end
  end

  def persist!
    #TODO: make sure this is correct
    #Start a transaction, we only want to create the assignment if we can create EVERYTHING in the assignment
    Assignment.transaction do
      if @assignment.save

        topics_list.each do |a|
          a.assignment = @assignment
          if !a.save
            raise ActiveRecord::Rollback
          end
        end

        due_dates_list.each do |a|
          a.assignment = @assignment
          if !a.save
            raise ActiveRecord::Rollback
          end
        end

        set_up_assignment_review
        # Update the assignment again to have the due_dates and sign_up_topics
        # This might need to be update?
        if !@assignment.save
          raise ActiveRecord::Rollback
          false
        end
      else
        raise ActiveRecord::Rollback
      end
      #if we've already made the assignment, don't bother trying to persist that
      #if !@assignment
        #@assignment = Assignment.create!(:name => assignment_name, :scope => assignment_scope, :course => assignment_course, :instructor => assignment_instructor, :max_team_size => assignment_max_team_size)
        #if !@assignment
          #raise ActiveRecord::Rollback
        #end
      #end
      #might need to set the assignment_id in each of these topics and due dates, not sure
      #the interconnections are difficult to figure out from the models

      #don't need to re-persist these topics, remove them from the "Queue"
      topics_list = []


      #same as the topics list
      due_dates_list = []
      true
    end
  end

end