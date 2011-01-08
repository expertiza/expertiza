require 'digest/sha1'

class User < ActiveRecord::Base
  has_many :participants, :class_name => 'Participant', :foreign_key => 'user_id'
  has_many :assignments, :through => :participants
  
  belongs_to :parent, :class_name => 'User', :foreign_key => 'parent_id'
  
  has_many :teams_users
  has_many :teams, :through => :teams_users
  
  validates_presence_of :name
  validates_uniqueness_of :name

  attr_accessor :clear_password
  attr_accessor :confirm_password
  
  def list_mine(object_type, user_id)
    object_type.find(:all, :conditions => ["instructor_id = ?", user_id])
  end
  
  def getAvailableUsers(name)    
    parents = Role.find(self.role_id).get_parents
    
    allUsers = User.find(:all, :conditions => ['name LIKE ?',"#{name}%"],:limit => 10)
    users = Array.new
    allUsers.each { | user | 
      role = Role.find(user.role_id)
      if parents.index(role) 
        users << user
      end
    }    
    return users 
  end

  def role
    if self.role_id
      @role ||= Role.find(self.role_id)
    end
    return @role
  end
    
  def before_save
    if self.clear_password  # Only update the password if it has been changed
      self.password_salt = self.object_id.to_s + rand.to_s
      self.password = Digest::SHA1.hexdigest(self.password_salt +
                                             self.clear_password)
    end
  end

  def after_save
    self.clear_password = nil
  end

  def check_password(clear_password)
    self.password == Digest::SHA1.hexdigest(self.password_salt.to_s +
                                                 clear_password)
  end
  
  # Generate email to user with new password
  #ajbudlon, sept 07, 2007   
  def send_password(clear_password) 
    self.password = Digest::SHA1.hexdigest(self.password_salt.to_s + clear_password)
    self.save
    
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

end
