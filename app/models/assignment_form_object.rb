#TODO: Not working yet

class AssignmentFormObject
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_reader :assignment, :topics, :due_dates

  attribute :assignment_name, :assignment_scope, :assignment_course, :assignment_instructor, :assignment_wiki_type, :assignment_max_team_size, :topics_list, :due_dates_list

  #TODO: I have a feeling these validations are not correct

  # the following validation and the one underneath it may do the same thing
  validates :assignment_name, presence: true, uniqueness: {scope: :course_id}
  #validates_uniqueness_of :assignment_name, :assignment_scope => :course_id


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

  def initialize
    topics_list = Array.new
    due_dates_list = Array.new
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