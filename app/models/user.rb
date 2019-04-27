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
  has_many :teams_users, dependent: :destroy
  has_many :teams, through: :teams_users
  has_many :sent_invitations, class_name: 'Invitation', foreign_key: 'from_id', dependent: :destroy
  has_many :received_invitations, class_name: 'Invitation', foreign_key: 'to_id', dependent: :destroy
  has_many :children, class_name: 'User', foreign_key: 'parent_id'
  has_many :track_notifications, dependent: :destroy
  belongs_to :parent, class_name: 'User'
  belongs_to :role
  validates :name, presence: true
  validates :name, uniqueness: true
  validates :name, format: {without: /\s/}

  validates :email, presence: {message: "can't be blank"}
  validates :email, format: {with: /\A[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\z/i, allow_blank: true}

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
    return true if self.teaching_assistant_for?(user)
    return true if self.recursively_parent_of(user)
    false
  end

  #goes up the chain of parents until one of the cases is met
  def recursively_parent_of(user)
    p = user.parent
    return false if p.nil?
    return true if p == self
    return false if p.role.super_admin?
    self.recursively_parent_of(p)
  end

  def get_user_list(search_name = '', search_id = '', search_fname = '', search_email = '')
    user_list = []
    # If the user is a super admin, fetch all users
    user_list = SuperAdministrator.get_user_list if self.role.super_admin?

    # If the user is an instructor, fetch all users in his course/assignment
    user_list = Instructor.get_user_list(self) if self.role.instructor?

    # If the user is a TA, fetch all users in his courses
    user_list = Ta.get_user_list(self) if self.role.ta?

    # Add the children to the list
    unless self.role.super_admin?
      User.all.find_each do |u|
        if recursively_parent_of(u)
          user_list << u unless user_list.include?(u)
        end
      end
    end
    reg_name, reg_fname, reg_email = get_user_regex_values(search_name, search_fname, search_email)
    s = user_list.select do |item|
      reg_name.match(item.name) \
      and reg_fname.match(item.fullname) \
      and reg_email.match(item.email)
    end
    # and reg_id.match(item.id)
    s.uniq
  end

  def get_user_regex_values(search_name, search_fname, search_email)
    reg_name = Regexp.new(search_name)
    # reg_id = Regexp.new(search_id)
    reg_fname = Regexp.new(search_fname)
    reg_email = Regexp.new(search_email)
    return reg_name, reg_fname, reg_email
  end

  # Zhewei: anonymized view for demo purposes - 1/3/2018
  def self.anonymized_view?(ip_address = nil)
    anonymized_view_starter_ips = $redis.get('anonymized_view_starter_ips') || ''
    return true if ip_address and anonymized_view_starter_ips.include? ip_address
    false
  end

  def name(ip_address = nil)
    User.anonymized_view?(ip_address) ? self.role.name + ' ' + self.id.to_s : self[:name]
  end

  def fullname(ip_address = nil)
    User.anonymized_view?(ip_address) ? self.role.name + ', ' + self.id.to_s : self[:fullname]
  end

  def first_name(ip_address = nil)
    User.anonymized_view?(ip_address) ? self.role.name : fullname.try(:[], /,.+/).try(:[], /\w+/) || ''
  end

  def email(ip_address = nil)
    User.anonymized_view?(ip_address) ? self.role.name + '_' + self.id.to_s + '@mailinator.com' : self[:email]
  end

  def super_admin?
    role.name == 'Super-Administrator'
  end

  delegate :admin?, to: :role

  delegate :student?, to: :role

  def creator_of?(user)
    self == user.creator
  end

  # Function which has a MailerHelper which sends the mail welcome email to the user after signing up
  def email_welcome
    MailerHelper.send_mail_to_user(self, "Your Expertiza password has been created", "user_welcome", password)
  end

  def valid_password?(password)
    Authlogic::CryptoProviders::Sha1.stretches = 1
    Authlogic::CryptoProviders::Sha1.matches?(crypted_password, self.password_salt.to_s + password)
  end

  # Resets the password to be mailed to the user
  def reset_password
    randomize_password
    save
    password
  end

  def self.import(row_hash, _row_header, session, id = nil)
    raise ArgumentError, "Only #{row_hash.length} column(s) is(are) found. It must contain at least username, full name, email." if row_hash.length < 3
    user = User.find_by_name(row_hash[:name])
    if user.nil? #set user info because it does exist currently
      user = User.self_import_set_user_info(row_hash, session)
    else #import existing user info
      user = User.self_import_user_info(user, row_hash, session)
    end
  end

  #initial account setup
  def self.self_import_set_user_info(row_hash, session)
    attributes = ImportFileHelper.define_attributes(row_hash)
    user = ImportFileHelper.create_new_user(attributes, session)
    password = user.reset_password
    MailerHelper.send_mail_to_user(user, "Your Expertiza account has been created.", "user_welcome", password).deliver
    return user
  end

  #existing account information
  def self.self_import_user_info(user, row_hash, session)
    user.email = row_hash[:email]
    user.fullname = row_hash[:fullname]
    user.parent_id = (session[:user]).id
    user.save
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
  def self.find_by_shortname(login)
    items = login.split("@")
    shortName = items[0]
    userList = User.where("name = ?", shortName)
    userList.first if !userList.nil? && userList.length == 1
  end

  def self.find_by_login(login)
    user = User.find_by(email: login)
    if user.nil? #if the user is empty, find one by the shortname
      user = User.find_by_shortname(login)
    end
    return user
  end

  def set_instructor(new_assignment)
    new_assignment.instructor_id = self.id
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
    else raise NotImplementedError, "for role #{role.name}"
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
        AssignmentParticipant.grant_publishing_rights(new_key.to_pem, [participant]) if participant.permission_granted
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

  #exports ALL of the users' name, role, parent, email, and handle to a CSV file
  def self.export(csv, _parent_id, options)
    users = User.all
    users.each do |user|
      tcsv = []
      tcsv.push(user.name, user.fullname, user.email) if options["personal_details"] == "true"
      tcsv.push(user.role.name) if options["role"] == "true"
      tcsv.push(user.parent.name) if options["parent"] == "true"
      tcsv.push(user.email_on_submission, user.email_on_review, user.email_on_review_of_review, user.copy_of_emails) if options["email_options"] == "true"
      tcsv.push(user.handle) if options["handle"] == "true"
      csv << tcsv
    end
  end

  def creator
    parent
  end

  def self.export_fields(options)
    fields = []
    fields.push("name", "full name", "email") if options["personal_details"] == "true"
    fields.push("role") if options["role"] == "true"
    fields.push("parent") if options["parent"] == "true"
    fields.push("email on submission", "email on review", "email on metareview") if options["email_options"] == "true"
    fields.push("handle") if options["handle"] == "true"
    fields
  end

  #returns the user specified by the params
  #if user doesn't exist, starts account creation process
  def self.from_params(params)
    user = if params[:user_id]
             User.find(params[:user_id])
           else
             User.find_by name: params[:user][:name]
           end
    if user.nil?
      newuser = url_for controller: 'users', action: 'new'
      raise "Please <a href='#{newuser}'>create an account</a> for this user to continue."
    end
    user
  end

  #returns true if the student is a teaching assistant
  def teaching_assistant_for?(student)
    return false unless teaching_assistant?
    return false if student.role.name != 'Student'
    # We have to use the Ta object instead of User object
    # because single table inheritance is not currently functioning
    ta = Ta.find(id)
    return true if ta.courses_assisted_with.any? do |c|
      c.assignments.map(&:participants).flatten.map(&:user_id).include? student.id
    end
  end

  def teaching_assistant?
    return true if self.role.ta?
  end

  def self.search_users(role, user_id, letter, search_by)
    # some change here
    key_word = {'1' => 'name', '2' => 'fullname', '3' => 'email'}
    sql = "(role_id in (?) or id = ?) and #{key_word[search_by]} like ?"
    if key_word.include? search_by
      search_filter = '%' + letter + '%'
      users = User.order('name').where(sql, role.get_available_roles, user_id, search_filter)
    else # default used when clicking on letters
      search_filter = letter + '%'
      users = User.order('name').where("(role_id in (?) or id = ?) and name like ?", role.get_available_roles, user_id, search_filter)
    end
    users
  end
end
