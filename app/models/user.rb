class User < ActiveRecord::Base

  acts_as_authentic do |config|
    config.validates_uniqueness_of_email_field_options = {:if => lambda { false }} # Don't validate email uniqueness
    config.crypto_provider = Authlogic::CryptoProviders::Sha1
    Authlogic::CryptoProviders::Sha1.join_token = ''
    Authlogic::CryptoProviders::Sha1.stretches = 1
  end

  has_many :participants, :class_name => 'Participant', :foreign_key => 'user_id', :dependent => :destroy
  has_many :assignment_participants, :class_name => 'AssignmentParticipant', :foreign_key => 'user_id', :dependent => :destroy
  has_many :assignments, :through => :participants

  has_many :teams_users, :dependent => :destroy
  has_many :teams, :through => :teams_users
  has_many :sent_invitations, class_name: 'Invitation', foreign_key: 'from_id', dependent: :destroy
  has_many :received_invitations, class_name: 'Invitation', foreign_key: 'to_id', dependent: :destroy

  has_many :children, class_name: 'User', :foreign_key => 'parent_id'
  belongs_to :parent, class_name: 'User'
  belongs_to :role

  validates_presence_of :name
  validates_uniqueness_of :name

  validates_presence_of :email, :message => "can't be blank"
  validates_format_of :email, :with => /\A[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\z/i, :allow_blank => true

  before_validation :randomize_password, :if => lambda { |user| user.new_record? && user.password.blank? } # AuthLogic
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

  def bookmark_rated?(bmapping_id)
    BmappingRatings.where(["bmapping_id = #{bmapping_id} AND user_id = #{self.id}"]).first
  end

  def bookmark_added?(bmapping_id)
    Bmapping.where(["id = #{bmapping_id} AND user_id = #{self.id}"]).first
  end



  def list_mine(object_type, user_id)
    object_type.where(["instructor_id = ?", user_id])
  end

  def get_available_users(name)
    lesser_roles = role.get_parents
    all_users = User.all(:conditions => ['name LIKE ?', "#{name}%"], :limit => 20) # higher limit, since we're filtering
    visible_users = all_users.select{|user| lesser_roles.include? user.role}
    return visible_users[0,10] # the first 10
  end

  def can_impersonate?(user)
    user &&
      self == user || # can impersonate self
      self.is_teaching_assistant_for?(user) || #TAs can impersonate their students
      self.is_creator_of?(user) ||
      can_impersonate?(user.parent) # recursive
  end

  def first_name
    fullname.try(:[], /,.+/).try(:[], /\w+/) || ''
  end

  def super_admin?
    role.name == 'Super-Administrator'
  end

  def admin?
    role.admin?
  end

  def student?
    role.student?
  end

  def is_creator_of?(user)
    self == user.creator
  end

  def assign_random_password
    if self.password.blank?
      self.password = self.random_password
    end
  end

  # Function which has a MailerHelper which sends the mail welcome email to the user after signing up
  def email_welcome
    MailerHelper::send_mail_to_user(self, "Your Expertiza password has been created", "user_welcome", password)
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

  def self.random_password(size=8)
    random_pronouncable_password((size/2).round) + rand.to_s[2,3]
  end

  def self.import(row,session,id = nil)
    if row.length != 4
      raise ArgumentError, "Not enough items"
    end
    user = User.find_by_name(row[0])

    if user == nil
      attributes = ImportFileHelper::define_attributes(row)
      user = ImportFileHelper::create_new_user(attributes,session)
    else
      user.password = row[3].strip
      user.email = row[2].strip
      user.fullname = row[1].strip
      user.parent_id = (session[:user]).id
      user.save
    end
  end

  def get_author_name
    return self.fullname
  end

  def self.yesorno(elt)
    if elt==true
      "yes"
    elsif elt ==false
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
    if user == nil
      items = login.split("@")
      shortName = items[0]
      userList = User.where ["name =?",shortName]
      if userList != nil && userList.length == 1
        user = userList.first
      end
    end
    return user
  end

  def set_instructor (new_assign)
    new_assign.instructor_id = self.id
  end

  def get_instructor
    self.id
  end

  def instructor_id
    case role.name
    when 'Instructor' then id
    when 'Teaching Assistant' then Ta.get_my_instructor(id)
    else raise NotImplementedError.new "for role #{role.name}"
    end
  end

  def set_courses_to_assignment
    @courses = Course.where(instructor_id: self.id).order(:name)
  end

  # generate a new RSA public/private key pair and create our own X509 digital certificate which we
  # save in the database. The private key is returned by the method but not saved.
  def generate_keys
    # check if we are replacing a digital certificate already generated
    replacing_key = true if (!self.digital_certificate.nil?)

    # generate the new key pair
    new_key = OpenSSL::PKey::RSA.generate( 1024 )
    self.public_key = new_key.public_key.to_pem

    save

    # when replacing an existing key, update any digital signatures made previously with the new key
    if (replacing_key)
      participants = AssignmentParticipant.where(user_id: self.id)
      for participant in participants
        if (participant.permission_granted)
          AssignmentParticipant.grant_publishing_rights(new_key.to_pem, [ participant ])
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

  def self.export(csv, parent_id, options)
    users = User.all
    users.each {|user|
      tcsv = Array.new
      if (options["personal_details"] == "true")
        tcsv.push(user.name, user.fullname, user.email)
      end
      if (options["role"] == "true")
        tcsv.push(user.role.name)
      end
      if (options["parent"] == "true")
        tcsv.push(user.parent.name)
      end
      if (options["email_options"] == "true")
        tcsv.push(user.email_on_submission, user.email_on_review, user.email_on_review_of_review, user.copy_of_emails)
      end
      if (options["handle"] == "true")
        tcsv.push(user.handle)
      end
      csv << tcsv
    }
  end

  def creator
    parent
  end

  def self.get_export_fields(options)
    fields = Array.new
    if (options["personal_details"] == "true")
      fields.push("name", "full name", "email")
    end
    if (options["role"] == "true")
      fields.push("role")
    end
    if (options["parent"] == "true")
      fields.push("parent")
    end
    if (options["email_options"] == "true")
      fields.push("email on submission", "email on review", "email on metareview")
    end
    if (options["handle"] == "true")
      fields.push("handle")
    end
    return fields
  end

  def self.from_params(params)
    if params[:user_id]
      user = User.find(params[:user_id])
    else
      user = User.find_by_name(params[:user][:name])
    end
    if user.nil?
      newuser = url_for :controller => 'users', :action => 'new'
      raise "Please <a href='#{newuser}'>create an account</a> for this user to continue."
    end
    return user
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
    false
  end
end
