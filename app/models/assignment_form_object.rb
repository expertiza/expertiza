#TODO: Not working yet

class AssignmentFormObject
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_reader :assignment, :topics, :due_dates

  attribute :assignment_name, :assignment_scope

  validates_presence_of :assignment_name
  validates_uniqueness_of :assignment_name, :assignment_scope => :course_id
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

  private

  def persist!
    @company = Company.create!(name: company_name)
    @user = @company.users.create!(name: name, email: email)
  end

end