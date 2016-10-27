class User < ActiveRecord::Base
  acts_as_authentic do |config|
    config.validates_uniqueness_of_email_field_options = {if: -> { false }} # Don't validate email uniqueness
    config.crypto_provider = Authlogic::CryptoProviders::Sha1
    Authlogic::CryptoProviders::Sha1.join_token = ''
    Authlogic::CryptoProviders::Sha1.stretches = 1
  end

  has_many :participants, class_name: 'Participant', foreign_key: 'user_id', dependent: :destroy
  has_many :assignment_participants, class_name: 'AssignmentParticipant', foreign_key: 'user_id', dependent: :destroy
  has_many :assignments, through: :participants
  has_many :bids, dependent: :destroy

  has_many :teams_users, dependent: :destroy
  has_many :teams, through: :teams_users
  has_many :sent_invitations, class_name: 'Invitation', foreign_key: 'from_id', dependent: :destroy
  has_many :received_invitations, class_name: 'Invitation', foreign_key: 'to_id', dependent: :destroy

  has_many :children, class_name: 'User', foreign_key: 'parent_id'
  belongs_to :parent, class_name: 'User'
  belongs_to :role

  validates_presence_of :name
  validates_uniqueness_of :name

  validates_presence_of :email, message: "can't be blank"
  validates_format_of :email, with: /\A[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\z/i, allow_blank: true

  before_validation :randomize_password, if: ->(user) { user.new_record? && user.password.blank? } # AuthLogic
  after_create :email_welcome

  scope :superadministrators, -> { where role_id: Role.superadministrator }
  scope :superadmins, -> { superadministrators }
  scope :administrators, -> { where role_id: Role.administrator }
  scope :admins, -> { administrators }
  scope :instructors, -> { where role_id: Role.instructor }
  scope :tas, -> { where role_id: Role.ta }
  scope :students, -> { where role_id: Role.student }

  has_paper_trail

  def salt_first?
    true
  end

  def list_mine(object_type, user_id)
    object_type.where(["instructor_id = ?", user_id])
  end

  def get_available_users(name)
    lesser_roles = role.get_parents
    all_users = User.all(conditions: ['name LIKE ?', "#{name}%"], limit: 20) # higher limit, since we're filtering
    visible_users = all_users.select {|user| lesser_roles.include? user.role }
    visible_users[0, 10] # the first 10
  end

  def can_impersonate?(user)
    return true if self.role.super_admin?
    return true if self.is_teaching_assistant_for?(user)
    return true if self.is_recursively_parent_of(user)
    false
  end

  def is_recursively_parent_of(user)
    p = user.parent
    return false if p.nil?
    return true if p == self
    return false if p.role.super_admin?
    self.is_recursively_parent_of(p)
  end

  def get_user_list
    user_list = []

    # If the user is a super admin, fetch all users
    if self.role.super_admin?
      User.all.find_each do |user|
        user_list << user
      end
    end

    # If the user is an instructor, fetch all users in his course/assignment
    if self.role.instructor?
      participants = []
      Course.where(instructor_id: self.id).find_each do |course|
        participants << course.get_participants
      end
      Assignment.where(instructor_id: self.id).find_each do |assignment|
        participants << assignment.participants
      end
      participants.each do |p_s|
        next if p_s.empty?
        p_s.each do |p|
          user_list << p.user if self.role.hasAllPrivilegesOf(p.user.role)
        end
      end
    end

    # If the user is a TA, fetch all users in his courses
    if self.role.ta?
      courses = Ta.get_mapped_courses(self.id)
      participants = []
      courses.each do |course_id|
        course = Course.find(course_id)
        participants << course.get_participants
      end
      participants.each do |p_s|
        next if p_s.empty?
        p_s.each do |p|
          user_list << p.user if self.role.hasAllPrivilegesOf(p.user.role)
        end
      end
    end

    # Add the children to the list
    unless self.role.super_admin?
      User.all.find_each do |u|
        if is_recursively_parent_of(u)
          user_list << u unless user_list.include?(u)
        end
      end
    end

    user_list
  end

  def first_name
    fullname.try(:[], /,.+/).try(:[], /\w+/) || ''
  end

  def super_admin?
    role.name == 'Super-Administrator'
  end

  delegate :admin?, to: :role

  delegate :student?, to: :role

  def is_creator_of?(user)
    self == user.creator
  end

  # Function which has a MailerHelper which sends the mail welcome email to the user after signing up
  def email_welcome
    MailerHelper.send_mail_to_user(self, "Your Expertiza password has been created", "user_welcome", password)
  end

  def valid_password?(password)
    Authlogic::CryptoProviders::Sha1.stretches = 1
    Authlogic::CryptoProviders::Sha1.matches?(crypted_password, *[self.password_salt.to_s + password])
  end

  # Resets the password to be mailed to the user
  def reset_password
    randomize_password
    save
    password
  end

  def self.import(row, _row_header, session, _id = nil)
    if row.length != 3
      raise ArgumentError, "Not enough items: expect 3 columns: your login name, your full name (first and last name, not seperated with the delimiter), and your email."
    end
    user = User.find_by_name(row[0])

    if user.nil?
      attributes = ImportFileHelper.define_attributes(row)
      user = ImportFileHelper.create_new_user(attributes, session)
      password = user.reset_password # the password is reset
      MailerHelper.send_mail_to_user(user, "Your Expertiza account has been created.", "user_welcome", password).deliver
    else
      user.email = row[2].strip
      user.fullname = row[1].strip
      user.parent_id = (session[:user]).id
      user.save
    end
  end

  def self.yesorno(elt)
    if elt == true
      "yes"
    elsif elt == false
      "no"
    else
      ""
    end
  end

  # locate User based on provided login.
  # If user supplies e-mail or name, the
  # helper will try to find that User account.
  def self.find_by_login(login)
    user = User.find_by_email(login)
    if user.nil?
      items = login.split("@")
      shortName = items[0]
      userList = User.where ["name =?", shortName]
      user = userList.first if !userList.nil? && userList.length == 1
    end
    user
  end

  def set_instructor(new_assign)
    new_assign.instructor_id = self.id
  end

  def get_instructor
    self.id
  end

  def instructor_id
    case role.name
    when 'Super-Administrator' then id
    when 'Administrator' then id
    when 'Instructor' then id
    when 'Teaching Assistant' then Ta.get_my_instructor(id)
    else raise NotImplementedError.new "for role #{role.name}"
    end
  end

  # generate a new RSA public/private key pair and create our own X509 digital certificate which we
  # save in the database. The private key is returned by the method but not saved.
  def generate_keys
    # check if we are replacing a digital certificate already generated
    replacing_key = true unless self.digital_certificate.nil?

    # generate the new key pair
    new_key = OpenSSL::PKey::RSA.generate(1024)
    self.public_key = new_key.public_key.to_pem

    save

    # when replacing an existing key, update any digital signatures made previously with the new key
    if replacing_key
      participants = AssignmentParticipant.where(user_id: self.id)
      for participant in participants
        if participant.permission_granted
          AssignmentParticipant.grant_publishing_rights(new_key.to_pem, [participant])
        end
      end
    end

    # return the new private key
    new_key.to_pem
    end

  def initialize(attributes = nil)
    super(attributes)
    Authlogic::CryptoProviders::Sha1.stretches = 1
    @email_on_review = true
    @email_on_submission = true
    @email_on_review_of_review = true
    @copy_of_emails = false
  end

  def self.export(csv, _parent_id, options)
    users = User.all
    users.each do |user|
      tcsv = []
      if options["personal_details"] == "true"
        tcsv.push(user.name, user.fullname, user.email)
      end
      tcsv.push(user.role.name) if options["role"] == "true"
      tcsv.push(user.parent.name) if options["parent"] == "true"
      if options["email_options"] == "true"
        tcsv.push(user.email_on_submission, user.email_on_review, user.email_on_review_of_review, user.copy_of_emails)
      end
      tcsv.push(user.handle) if options["handle"] == "true"
      csv << tcsv
    end
  end

  def creator
    parent
  end

  def self.export_fields(options)
    fields = []
    if options["personal_details"] == "true"
      fields.push("name", "full name", "email")
    end
    fields.push("role") if options["role"] == "true"
    fields.push("parent") if options["parent"] == "true"
    if options["email_options"] == "true"
      fields.push("email on submission", "email on review", "email on metareview")
    end
    fields.push("handle") if options["handle"] == "true"
    fields
  end

  def self.from_params(params)
    user = if params[:user_id]
             User.find(params[:user_id])
           else
             User.find_by_name(params[:user][:name])
           end
    if user.nil?
      newuser = url_for controller: 'users', action: 'new'
      raise "Please <a href='#{newuser}'>create an account</a> for this user to continue."
    end
    user
  end

  def is_teaching_assistant_for?(student)
    return false unless is_teaching_assistant?
    return false if student.role.name != 'Student'
    # We have to use the Ta object instead of User object
    # because single table inheritance is not currently functioning
    ta = Ta.find(id)
    return true if ta.courses_assisted_with.any? do |c|
      c.assignments.map(&:participants).flatten.map(&:user_id).include? student.id
    end
  end

  def is_teaching_assistant?
    return true if self.role.ta?
  end

  def self.search_users(role, user_id, letter, search_by)
    if search_by == '1' # search by user name
      search_filter = '%' + letter + '%'
      users = User.order('name').where("(role_id in (?) or id = ?) and name like ?", role.get_available_roles, user_id, search_filter)
    elsif search_by == '2' # search by full name
      search_filter = '%' + letter + '%'
      users = User.order('name').where("(role_id in (?) or id = ?) and fullname like ?", role.get_available_roles, user_id, search_filter)
    elsif search_by == '3' # search by email
      search_filter = '%' + letter + '%'
      users = User.order('name').where("(role_id in (?) or id = ?) and email like ?", role.get_available_roles, user_id, search_filter)
    else # default used when clicking on letters
      search_filter = letter + '%'
      users = User.order('name').where("(role_id in (?) or id = ?) and name like ?", role.get_available_roles, user_id, search_filter)
    end
    users
  end
end