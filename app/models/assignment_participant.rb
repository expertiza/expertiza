class AssignmentParticipant < Participant  
  require 'wiki_helper'
  belongs_to :assignment, :class_name => 'Assignment', :foreign_key => 'parent_id' 
  has_many :review_mappings, :class_name => 'ParticipantReviewResponseMap', :foreign_key => 'reviewee_id'
  belongs_to :user
  validates_presence_of :handle

  # CSC/ECE-517 - Add support for hosted documents (ie Google Docs)
  has_many :participant_hosted_documents
  
  def fullname
    self.user.fullname
  end
  
  def name
    self.user.name
  end

  def get_scores(questions)
      scores = Hash.new
      scores[:participant] = self
      assignment.questionnaires.each{
        | questionnaire |
        scores[questionnaire.symbol] = Hash.new
        scores[questionnaire.symbol][:assessments] = questionnaire.get_assessments_for(self)
        scores[questionnaire.symbol][:scores] = Score.compute_scores(scores[questionnaire.symbol][:assessments], questions[questionnaire.symbol])        
      }  
      scores[:total_score] = compute_total_score(scores)
    return scores
  end

  def get_hyperlinks             
    if self.team     
      links = self.team.get_hyperlinks     
    else        
      links = Array.new  
      if self.submitted_hyperlink and self.submitted_hyperlink.strip.length > 0
        links << self.submitted_hyperlink
      end
    end
    
    return links
  end

  #Copy this participant to a course
  def copy(course_id)
    part = CourseParticipant.find_by_user_id_and_parent_id(self.user_id,course_id)
    if part.nil?
       CourseParticipant.create(:user_id => self.user_id, :parent_id => course_id)       
    end
  end  
  
  def get_course_string
    # if no course is associated with this assignment, or if there is a course with an empty title, or a course with a title that has no printing characters ...    
    begin
      course = Course.find(self.assignment.course.id)
      if course.name.strip.length == 0
        raise
      end
      return course.name 
    rescue      
      return "<center>&#8212;</center>" 
    end
  end
  
  def get_feedback
    return FeedbackResponseMap.get_assessments_for(self)      
  end
  
  def get_reviews
    if self.assignment.team_assignment
      return TeamReviewResponseMap.get_assessments_for(self.team)          
    else
      return ParticipantReviewResponseMap.get_assessments_for(self)
    end
  end
   
  def get_metareviews
    MetareviewResponseMap.get_assessments_for(self)  
  end
  
  def get_teammate_reviews
    TeammateReviewResponseMap.get_assessments_for(self)
  end
  
  def has_submissions    
    if (self.submitted_hyperlink and self.submitted_hyperlink.strip.length > 0)
      hplink = true
    else
      hplink = false
    end
    return ((get_submitted_files.length > 0) or 
            (get_wiki_submissions.length > 0) or 
            (hplink)) 
  end
 
  def get_submitted_files()
    files = Array.new
    if(self.directory_num)      
      files = get_files(self.get_path)
    end
    return files
  end  
  
  def get_files(directory)      
      files_list = Dir[directory + "/*"]
      files = Array.new
      for file in files_list            
        if File.directory?(file) then          
          dir_files = get_files(file)          
          dir_files.each{|f| files << f}
        end
        files << file               
      end      
      return files
  end
  
  def get_wiki_submissions
    currenttime = Time.now.month.to_s + "/" + Time.now.day.to_s + "/" + Time.now.year.to_s
 
    if self.assignment.team_assignment and self.assignment.wiki_type.name == "MediaWiki"
       submissions = Array.new
       if self.team
        self.team.get_participants.each {
          | user |
          val = WikiType.review_mediawiki_group(self.assignment.directory_path, currenttime, user.handle)         
          if val != nil
              submissions << val
          end                 
        }
       end
       return submissions
    elsif self.assignment.wiki_type.name == "MediaWiki"
       return WikiType.review_mediawiki(self.assignment.directory_path, currenttime, self.handle)       
    elsif self.assignment.wiki_type.name == "DocuWiki"
       return WikiType.review_docuwiki(self.assignment.directory_path, currenttime, self.handle)             
    else
       return Array.new
    end
  end    
  
  def name
    self.user.name
  end
    
  def team
    AssignmentTeam.get_team(self)
  end
  
  def compute_total_score(scores)     
    total = 0
    self.assignment.questionnaires.each{
      | questionnaire |      
      total += questionnaire.get_weighted_score(self.assignment, scores)
    }
    return total
  end  
  
  # provide import functionality for Assignment Participants
  # if user does not exist, it will be created and added to this assignment
  def self.import(row,session,id)    
    if row.length < 1
       raise ArgumentError, "No user id has been specified." 
    end
    user = User.find_by_name(row[0])        
    if (user == nil)
      if row.length < 4
        raise ArgumentError, "The record containing #{row[0]} does not have enough items."
      end
      attributes = ImportFileHelper::define_attributes(row)
      user = ImportFileHelper::create_new_user(attributes,session)
    end                  
    if Assignment.find(id) == nil
       raise ImportError, "The assignment with id \""+id.to_s+"\" was not found."
    end
    if (find(:all, {:conditions => ['user_id=? AND parent_id=?', user.id, id]}).size == 0)
          newpart = AssignmentParticipant.create(:user_id => user.id, :parent_id => id)
          newpart.set_handle()
    end             
  end  
  
  # provide export functionality for Assignment Participants
  def self.export(csv,parent_id)
     find_all_by_parent_id(parent_id).each{
          |part|
          user = part.user
          csv << [
            user.name,
            user.fullname,          
            user.email,
            user.role.name,
            user.parent.name,
            user.email_on_submission,
            user.email_on_review,
            user.email_on_review_of_review,
            part.handle
          ]
      } 
  end
  
  def self.get_export_fields
    fields = ["name","full name","email","role","parent","email on submission","email on review","email on metareview","handle"]
    return fields            
  end
  
  def get_hash(time_stamp)
    #Digest::SHA1.digest(self.assignment.name)
    
    hash_data = Digest::SHA1.digest(self.assignment.name.to_s)
    sign = hash_data + self.user.name.to_s + time_stamp.strftime("%Y-%m-%d %H:%M:%S")
    puts "-----------------------------------------------------"
    puts time_stamp.strftime("%Y-%m-%d %H:%M:%S")
    Digest::SHA1.digest(sign)
  end
  
  # grant publishing rights to one or more assignments. Using the supplied private key, 
  # digitial signatures are generated.
  # references:
  # http://stuff-things.net/2008/02/05/encrypting-lots-of-sensitive-data-with-ruby-on-rails/
  # http://rubyforge.org/tracker/?func=detail&atid=1698&aid=7218&group_id=426
  def self.grant_publishing_rights(privateKey, participants)
    for participant in participants
      time_now = Time.now.utc
      hash_data = participant.get_hash(time_now)
      private_key2 = OpenSSL::PKey::RSA.new(privateKey)
      cipher_text = Base64.encode64(private_key2.private_encrypt(hash_data))
      participant.digital_signature = cipher_text
      participant.time_stamp = time_now
      participant.update_attribute('permission_granted', 1)
     #now, check to make sure the digital signature is valid, if not raise error
     if(participant.verify_digital_signature(cipher_text))
        participant.save
      else
      	participant.digital_signature-nil
      	participant.time_stamp=nil
      	raise "invalid key"
      end
      
    end
  end
  
  # references:
  # http://stuff-things.net/2008/02/05/encrypting-lots-of-sensitive-data-with-ruby-on-rails/
  # http://rubyforge.org/tracker/?func=detail&atid=1698&aid=7218&group_id=426
  def verify_digital_signature(cipher_text)
    hash_data = get_hash(self.time_stamp)

    # get the public key from the digital certificate
    certificate1 = self.user.digital_certificate 
    cert = OpenSSL::X509::Certificate.new(certificate1)
    begin
      public_key1 = cert.public_key 
      public_key = OpenSSL::PKey::RSA.new(public_key1)
       
      clear_text = public_key.public_decrypt(Base64.decode64(cipher_text))
      if (hash_data == clear_text)
        true
      else
        false;
      end
      
      rescue Exception => msg  
        false
      end
  end
  
  #define a handle for a new participant
  def set_handle()
    if self.user.handle == nil or self.user.handle == ""
      self.handle = self.user.name
    else
      if AssignmentParticipant.find_all_by_parent_id_and_handle(self.assignment.id, self.user.handle).length > 0
        self.handle = self.user.name
      else
        self.handle = self.user.handle
      end
    end  
    self.save!
  end  
  
  def get_path
     path = self.assignment.get_path + "/"+ self.directory_num.to_s     
     return path
  end
  
  def update_resubmit_times
    new_submit = ResubmissionTime.new(:resubmitted_at => Time.now.to_s)
    self.resubmission_times << new_submit
  end
  
  def set_student_directory_num
    if self.directory_num.nil? or self.directory_num < 0           
      maxnum = AssignmentParticipant.find(:first, :conditions=>['parent_id = ?',self.parent_id], :order => 'directory_num desc').directory_num
      if maxnum
        dirnum = maxnum + 1
      else
        dirnum = 0
      end
      self.update_attribute('directory_num',dirnum)
      if self.assignment.team_assignment
        self.team.get_participants.each{
            | member |
            if member.directory_num == nil or member.directory_num < 0
              member.directory_num = self.directory_num
              member.save
            end
        }
      end
    end
  end   
end
