class User < ActiveRecord::Base
  
  acts_as_authentic do |config|
    config.password_field = :clear_password
    config.crypted_password_field = :password
    config.crypto_provider = Authlogic::CryptoProviders::Sha1
    config.salt_first = true
    Authlogic::CryptoProviders::Sha1.join_token = ''
    Authlogic::CryptoProviders::Sha1.stretches = 1
  end

  has_many :participants, :class_name => 'Participant', :foreign_key => 'user_id', :dependent => :destroy
  # FIXME:          :class_name should be AssignmentParticipant, probably. In most cases it's used that way. But all?
  has_many :assignments, :through => :participants
  
  belongs_to :parent, :class_name => 'User', :foreign_key => 'parent_id'
<<<<<<< HEAD
  has_many :bookmark_users
  has_many :teams_users
||||||| merged common ancestors
  
  has_many :teams_users
=======
  belongs_to :role
  
  has_many :teams_users, :dependent => :destroy
>>>>>>> master
  has_many :teams, :through => :teams_users
  has_many :bmappings
  validates_presence_of :name
  validates_presence_of :email, :message => "can't be blank; use anything@mailinator.com for test users"
  validates_format_of :email, :with => /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i, :allow_blank => true
  validates_uniqueness_of :name

  # happens in this order. see http://api.rubyonrails.org/classes/ActiveRecord/Callbacks.html
  before_validation :randomize_password, :if => lambda { |user| user.new_record? && user.clear_password.blank? } # AuthLogic
  after_create :email_welcome

  def list_mine(object_type, user_id)
    object_type.find(:all, :conditions => ["instructor_id = ?", user_id])
  end
  
  def get_available_users(name)    
    lesser_roles = role.get_parents
    all_users = User.find(:all, :conditions => ['name LIKE ?', "#{name}%"], :limit => 20) # higher limit, since we're filtering
    visible_users = all_users.select{|user| lesser_roles.include? user.role}
    return visible_users[0,10] # the first 10
  end

  def role
    if self.role_id
      @role ||= Role.find(self.role_id)
    end
    return @role
  end

  def can_impersonate?(other_user)
    return true if other_user == self # can impersonate self
    return false if other_user == other_user.parent # no one can impersonate a top-level parent (usually superadmin)
    return other_user.parent == self || can_impersonate?(other_user.parent) # recursive
  end

  def assign_random_password
    if self.password.blank?
      self.password = self.random_password
    end
  end

  def email_welcome
    Mailer.deliver_message(
        {:recipients => self.email,
         :subject => "Your Expertiza account has been created",
         :body => {
           :user => self,
           :password => clear_password, #FIXME
           :first_name => ApplicationHelper::get_user_first_name(self),
           :partial_name => "user_welcome"
         }
        }
    )
  end

  def check_password(clear_password)
    Authlogic::CryptoProviders::Sha1.stretches = 1
    Authlogic::CryptoProviders::Sha1.matches?(password, *[self.password_salt.to_s + clear_password])
  end

  # Generate email to user with new password
  def reset_and_mail_password
    self.reset_password!
    
    Mailer.deliver_message(
        {:recipients => self.email,
         :subject => "Your Expertiza password has been reset",
         :body => {
           :user => self,
           :password => clear_password,
           :first_name => ApplicationHelper::get_user_first_name(self),
           :partial_name => "send_password"
         }
        }
    )
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
        user.clear_password = row[3].strip
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
         userList = User.find(:all, {:conditions=> ["name =?",shortName]})
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
  
  def set_courses_to_assignment 
    @courses = Course.find_all_by_instructor_id(self.id, :order => 'name')    
  end

  # generate a new RSA public/private key pair and create our own X509 digital certificate which we 
  # save in the database. The private key is returned by the method but not saved.
  def generate_keys
    # check if we are replacing a digital certificate already generated
    replacing_key = true if (!self.digital_certificate.nil?)

    # generate the new key pair
    new_key = OpenSSL::PKey::RSA.generate( 1024 )
    new_public = new_key.public_key
    new_private = new_key.to_pem

    # create the X509 certificate on behalf of the user
    cert = OpenSSL::X509::Certificate.new
    cert.version = 1
    cert.subject = cert.issuer = OpenSSL::X509::Name.parse("/C="+self.id.to_s)
    cert.public_key = new_public
    
    # certificate will be valid for 1 year
    cert.not_before = Time.now
    cert.not_after = Time.now+3600*24*365
    
    # self-sign (we trust our own certificates) it using the private key
    cert.sign(new_key, OpenSSL::Digest::SHA1.new)
    
    # convert to a textual form and save it in the database
    self.digital_certificate = cert.to_pem
    self.save
    
    # when replacing an existing key, update any digital signatures made previously with the new key
    if (replacing_key)
      participants = AssignmentParticipant.find_all_by_user_id(self.id)
      for participant in participants
        if (participant.permission_granted && !participant.digital_signature.nil?)
          AssignmentParticipant.grant_publishing_rights(new_private, [ participant ]) 
        end
      end
    end
    
    # return the new private key
    new_private
  end

  def initialize(attributes = nil)
    super(attributes)
    Authlogic::CryptoProviders::Sha1.stretches = 1
    @email_on_review = true
    @email_on_submission = true
    @email_on_review_of_review = true
  end

end
