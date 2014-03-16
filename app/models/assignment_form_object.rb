#TODO: Not working yet

class AssignmentFormObject
  include Virtus.model

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_reader :assignment, :topics, :due_dates

  attribute :assignment_name, String
  attribute :assignment_course_id, Integer
  attribute :assignment_wiki_type_id, Integer
  attribute :assignment_max_team_size, Integer
  #:assignment_instructor, :topics_list, :due_dates_list

  #TODO: I have a feeling these validations are not correct

  validates :assignment_name, presence: true
  validates_uniqueness_of :assignment_name, :scope => :assignment_course_id

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

  # topic_params would be filtered by the controller to verify they are correct
  def add_topic(topic_params)
    #TODO: check if this is right
    topics_list.push(SignUpTopic.new(topic_params))
  end

  def add_due_date(due_date_params)
    #TODO: check if this is right
    due_dates_list.push(DueDate.new(due_date_params))
  end

  private

  def persist!
    #TODO: make sure this is correct
    #Start a transaction, we only want to create the assignment if we can create EVERYTHING in the assignment
    Assignment.transaction do
      @assignment = Assignment.create!(:name => assignment_name, :scope => assignment_scope, :course => assignment_course, :instructor => assignment_instructor, :max_team_size => assignment_max_team_size)
      if !@assignment
        raise ActiveRecord::Rollback
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
      due_dates_list.each do |a|
        a.assignment = @assignment
        if a.save
          due_dates.push(a)
        else
          raise ActiveRecord::Rollback
        end
      end
    end
  end

end