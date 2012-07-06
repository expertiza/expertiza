require 'uri'
require 'yaml'

# Code Review: Notice that Participant overloads two different concepts: 
#              contribution and participant (see fields of the participant table).
#              Consider creating a new table called contributions.
class AssignmentParticipant < Participant  
  require 'wiki_helper'
  
  belongs_to  :assignment, :class_name => 'Assignment', :foreign_key => 'parent_id' 
  has_many    :review_mappings, :class_name => 'ParticipantReviewResponseMap', :foreign_key => 'reviewee_id'
  has_many    :responses, :finder_sql => 'SELECT r.* FROM responses r, response_maps m, participants p WHERE r.map_id = m.id AND m.type = \'ParticipantReviewResponseMap\' AND m.reviewee_id = p.id AND p.id = #{id}'
  belongs_to  :user

  validates_presence_of :handle
  
# START of contributor methods, shared with AssignmentTeam

  def includes?(participant)
    return participant == self
  end

  def assign_reviewer(reviewer)
    ParticipantReviewResponseMap.create(:reviewee_id => self.id, :reviewer_id => reviewer.id,
      :reviewed_object_id => assignment.id)
  end

  # Evaluates whether this participant contribution was reviewed by reviewer
  # @param[in] reviewer AssignmentParticipant object 
  def reviewed_by?(reviewer)
    return ParticipantReviewResponseMap.count(:conditions => ['reviewee_id = ? AND reviewer_id = ? AND reviewed_object_id = ?', 
                                              self.id, reviewer.id, assignment.id]) > 0
  end

  def has_submissions?
    return ((get_submitted_files.length > 0) or 
            (get_wiki_submissions.length > 0) or 
            (get_hyperlinks_array.length > 0)) 
  end

# END of contributor methods
  
  def fullname
    self.user.fullname
  end
  
  def name
    self.user.name
  end

  # Return scores that this participant has given
  def get_scores(questions)
    scores = Hash.new
    scores[:participant] = self # This doesn't appear to be used anywhere
    self.assignment.questionnaires.each do |questionnaire|
      scores[questionnaire.symbol] = Hash.new
      scores[questionnaire.symbol][:assessments] = questionnaire.get_assessments_for(self)



      scores[questionnaire.symbol][:scores] = Score.compute_scores(scores[questionnaire.symbol][:assessments], questions[questionnaire.symbol])        
    end
    scores[:total_score] = assignment.compute_total_score(scores)
    return scores
  end

  # Appends the hyperlink to a list that is stored in YAML format in the DB
  # @exception  If is hyperlink was already there
  #             If it is an invalid URL
  def submmit_hyperlink(hyperlink)
    hyperlink.strip!
    raise "The hyperlink cannot be empty" if hyperlink.empty?

    url = URI.parse(hyperlink)

    # If not a valid URL, it will throw an exception
    Net::HTTP.start(url.host, url.port)

    hyperlinks = get_hyperlinks_array

    hyperlinks << hyperlink
    self.submitted_hyperlinks = YAML::dump(hyperlinks)

    self.save
  end

  # Note: This method is not used yet. It is here in the case it will be needed.
  # @exception  If the index does not exist in the array
  def remove_hyperlink(index)
    hyperlinks = get_hyperlinks
    raise "The link does not exist" unless index < hyperlinks.size

    hyperlinks.delete_at(index)
    self.submitted_hyperlinks = hyperlinks.empty? ? nil : YAML::dump(hyperlinks)

    self.save
  end

  # TODO:REFACTOR: This shouldn't be handled using an if statement, but using 
  # polymorphism for individual and team participants
  def get_hyperlinks         
    if self.team     
      links = self.team.get_hyperlinks     
    else        
      links = get_hyperlinks_array
    end

    return links
  end

  def get_hyperlinks_array
    self.submitted_hyperlinks.nil? ? [] : YAML::load(self.submitted_hyperlinks)
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
  def self.export(csv,parent_id,options)
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
  
  def self.get_export_fields(options)
    fields = ["name","full name","email","role","parent","email on submission","email on review","email on metareview","handle"]
    return fields            
  end
  
  # generate a hash string that we can digitally sign, consisting of the 
  # assignment name, user name, and time stamp passed in.
  def get_hash(time_stamp)
    # first generate a hash from the assignment name itself
    hash_data = Digest::SHA1.digest(self.assignment.name.to_s)
    
    # second generate a hash from the first hash plus the user name and time stamp
    sign = hash_data + self.user.name.to_s + time_stamp.strftime("%Y-%m-%d %H:%M:%S")
    Digest::SHA1.digest(sign)
  end
  
  # grant publishing rights to one or more assignments. Using the supplied private key, 
  # digital signatures are generated.
  # reference: http://stuff-things.net/2008/02/05/encrypting-lots-of-sensitive-data-with-ruby-on-rails/
  def self.grant_publishing_rights(privateKey, participants)
    for participant in participants
      # get the current time in UTC
      time_now = Time.now.utc
      
      # generate a hash to digitally sign
      hash_data = participant.get_hash(time_now)
            
      # generate a digital signature of the hash
      private_key2 = OpenSSL::PKey::RSA.new(privateKey)
      cipher_text = Base64.encode64(private_key2.private_encrypt(hash_data))
      
      # save the digital signature and the time stamp in the database.  Time stamp needs to be 
      # saved so we can generate the hash again later and compare it to the one digitally signed.
      participant.digital_signature = cipher_text
      participant.time_stamp = time_now
      
      #now, check to make sure the digital signature is valid, if not raise error
      if (participant.verify_digital_signature(cipher_text))
        participant.update_attribute('permission_granted', 1)
        participant.save
      else
        participant.update_attribute('permission_granted', 0)
        participant.digital_signature=nil
        participant.time_stamp=nil
        raise "invalid key"
      end
      
    end
  end
  
  # verify the digital signature is valid
  def verify_digital_signature(cipher_text)
    # get a hash based on the time stamp saved in the database
    hash_data = get_hash(self.time_stamp)

    # get the public key from the digital certificate saved in the database
    certificate1 = self.user.digital_certificate 
    cert = OpenSSL::X509::Certificate.new(certificate1)
    begin
      public_key1 = cert.public_key 
      public_key = OpenSSL::PKey::RSA.new(public_key1)
      
      # decrypt the hash from the passed in digital signature and compare to the one
      # we just generated to see if it is valid
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

private

  # Use submmit_hyperlink(), remove_hyperlink() instead
  def submitted_hyperlinks=(val)
    write_attribute :submitted_hyperlinks, val
  end
end

def get_topic_string
    if topic.nil? or topic.topic_name.empty?
      return "<center>&#8212;</center>"
    end
    return topic.topic_name
  end
