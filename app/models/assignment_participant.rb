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

  # OSS808 Change 28/10/2013
  # get_average_question_score
  has_many :collusion_cycles

  validates_presence_of :handle

  # Returns the average score of one question from all reviews for this user on this assignment as an floating point number
  # Params: question - The Question object to retrieve the scores from
  # OSS808 Change 26/10/2013
  # get_average_question_score
  def average_question_score(question)
    sum_of_scores = 0
    number_of_scores = 0

    self.response_maps.each do |response_map|
      # TODO There must be a more elegant way of doing this...
      unless response_map.response.nil?
        response_map.response.scores.each do |score|
          if score.question == question then
            sum_of_scores = sum_of_scores + score.score
            number_of_scores = number_of_scores + 1
          end
        end
      end
    end

    return 0 if number_of_scores == 0
    (((sum_of_scores.to_f / number_of_scores.to_f) * 100).to_i) / 100.0
  end

  # Returns the average score of all reviews for this user on this assignment

  def average_score
    return 0 if self.response_maps.size == 0

    sum_of_scores = 0

    self.response_maps.each do |response_map|
      if !response_map.response.nil?  then
        sum_of_scores = sum_of_scores + response_map.response.average_score
      end
    end

    (sum_of_scores / self.response_maps.size).to_i
  end

  def average_score_per_assignment(assignment_id)
    return 0 if self.response_maps.size == 0

    sum_of_scores = 0

    self.response_maps.metareview_response_maps.each do |metaresponse_map|
      if !metaresponse_map.response.nil? && response_map == assignment_id then
        sum_of_scores = sum_of_scores + response_map.response.average_score
      end
    end

    (sum_of_scores / self.response_maps.size).to_i
  end
  
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
    return ((submitted_files.length > 0) or
            (wiki_submissions.length > 0) or
            (get_hyperlinks_array.length > 0)) 
  end

  # all the participants in this assignment reviewed by this person
  #OSS808 Change 27/10/2013
  # Renamed to reviewees from get_reviewees
  # Commented Deprecated code and re-wrote the code

  def reviewees
    reviewees = []
    if self.assignment.team_assignment?
      #rmaps = ResponseMap.find(:all, :conditions => ["reviewer_id = #{self.id} AND type = 'TeamReviewResponseMap'"])
      rmaps = ResponseMap.find_all_by_reviewer_id_and_type(self.id,'TeamReviewResponseMap')
      rmaps.each do |rm|
        reviewees.concat(AssignmentTeam.find(rm.reviewee_id).participants)
      end
    else
      #rmaps = ResponseMap.find(:all, :conditions => ['reviewer_id = #{self.id} AND type = 'ParticipantReviewResponseMap'"])
      rmaps = ResponseMap.find_all_by_reviewer_id_and_type(self.id,'ParticipantReviewResponseMap')
      rmaps.each do |rm|
        reviewees.push(AssignmentParticipant.find(rm.reviewee_id))
      end
    end
   return reviewees
  end
  
  # all the participants in this assignment who have reviewed this person
  #OSS808 Change 27/10/2013
  # Renamed to reviewers from get_reviewers
  # Commented Deprecated code and re wrote the code

  def get_reviewers
    reviewers = []
    if self.assignment.team_assignment? && self.team
      #rmaps = ResponseMap.find(:all, :conditions => ["reviewee_id = #{self.team.id} AND type = 'TeamReviewResponseMap'"])
      rmaps = ResponseMap.find_all_by_reviewee_id_and_type(self.team.id,'TeamReviewResponseMap')
    else
      #rmaps = ResponseMap.find(:all, :conditions => ["reviewee_id = #{self.id} AND type = 'ParticipantReviewResponseMap'"])
      rmaps = ResponseMap.find_all_by_reviewee_id_and_type(self.id,'ParticipantReviewResponseMap')
    end
    rmaps.each do |rm|
       reviewers.push(AssignmentParticipant.find(rm.reviewer_id))
    end
    return reviewers  
  end

  # OSS808 Change 28/10/2013
  # Moved to class CollusionCycle
=begin
  # Cycle data structure
  # Each edge of the cycle stores a participant and the score given by to the participant by the reviewer.
  # Consider a 3 node cycle: A --> B --> C --> A (A reviewed B; B reviewed C and C reviewed A)
  # For the above cycle, the data structure would be: [[A, SCA], [B, SAB], [C, SCB]], where SCA is the score given by C to A.

  def get_two_node_cycles
    cycles = []
    self.get_reviewers.each do |ap|
      if ap.get_reviewers.include?(self)
        self.get_reviews_by_reviewer(ap).nil? ? next : s01 = self.get_reviews_by_reviewer(ap).get_total_score
        ap.get_reviews_by_reviewer(self).nil? ? next : s10 = ap.get_reviews_by_reviewer(self).get_total_score
        cycles.push([[self, s01], [ap, s10]])
      end
    end
    return cycles
  end

  def get_three_node_cycles
    cycles = []
    self.get_reviewers.each do |ap1|
      ap1.get_reviewers.each do |ap2|
        if ap2.get_reviewers.include?(self)
          self.get_reviews_by_reviewer(ap1).nil? ? next : s01 = self.get_reviews_by_reviewer(ap1).get_total_score
          ap1.get_reviews_by_reviewer(ap2).nil? ? next : s12 = ap1.get_reviews_by_reviewer(ap2).get_total_score
          ap2.get_reviews_by_reviewer(self).nil? ? next : s20 = ap2.get_reviews_by_reviewer(self).get_total_score
          cycles.push([[self, s01], [ap1, s12], [ap2, s20]])
        end
      end
    end
    return cycles
  end

  def get_four_node_cycles
    cycles = []
    self.get_reviewers.each do |ap1|
      ap1.get_reviewers.each do |ap2|
        ap2.get_reviewers.each do |ap3|
          if ap3.get_reviewers.include?(self)
            self.get_reviews_by_reviewer(ap1).nil? ? next : s01 = self.get_reviews_by_reviewer(ap1).get_total_score
            ap1.get_reviews_by_reviewer(ap2).nil? ? next : s12 = ap1.get_reviews_by_reviewer(ap2).get_total_score
            ap2.get_reviews_by_reviewer(ap3).nil? ? next : s23 = ap2.get_reviews_by_reviewer(ap3).get_total_score
            ap3.get_reviews_by_reviewer(self).nil? ? next : s30 = ap3.get_reviews_by_reviewer(self).get_total_score
            cycles.push([[self, s01], [ap1, s12], [ap2, s23], [ap3, s30]])
          end
        end
      end
    end
    return cycles
  end

  # Per cycle
  def get_cycle_similarity_score(cycle)
    similarity_score = 0.0
    count = 0.0
    for pivot in 0 ... cycle.size-1 do
      pivot_score = cycle[pivot][1]
      # puts "Pivot:" + cycle[pivot][1].to_s
      for other in pivot+1 ... cycle.size do
        # puts "Other:" + cycle[other][1].to_s
        similarity_score = similarity_score + (pivot_score - cycle[other][1]).abs
        count = count + 1.0
      end
    end
    similarity_score = similarity_score / count unless count == 0.0
    return similarity_score
  end

  # Per cycle
  def get_cycle_deviation_score(cycle)
    deviation_score = 0.0
    count = 0.0
    for member in 0 ... cycle.size do
      participant = AssignmentParticipant.find(cycle[member][0].id)
      total_score = participant.get_review_score
      deviation_score = deviation_score + (total_score - cycle[member][1]).abs
      count = count + 1.0
    end
    deviation_score = deviation_score / count unless count == 0.0
    return deviation_score
  end
=end

  #OSS808 Change 28/10/2013
  #created a new method collusion_cycles to access cycles related code

  def collusion_cycles
    self.collusion_cycles=CollusionCycle.two_node_cycles
    self.collusion_cycles<<CollusionCycle.three_node_cycles
    self.collusion_cycles<<CollusionCycle.four_node_cycles
    similarity_score= CollusionCycle.cycle_similarity_score(self.collusion_cycles)
    deviation_score=CollusionCycle.cycle_deviation_score(self.collusion_cycles)
  end

  #OSS808 Change 27/10/2013
  # Renamed to review_score from get_review_score

  def review_score
    review_questionnaire = self.assignment.questionnaires.select {|q| q.type == "ReviewQuestionnaire"}[0]
    assessment = review_questionnaire.get_assessments_for(self)
    return (Score.compute_scores(assessment, review_questionnaire.questions)[:avg] / 100.00) * review_questionnaire.max_possible_score.to_f    
  end

  #OSS808 Change 27/10/2013
  #Method redundant, already in participant.rb

  #def fullname
   # self.user.fullname
  #end

  #OSS808 Change 27/10/2013
  # Method redundant, already in participant.rb

=begin
  def name
    self.user.name
  end
=end

  # Return scores that this participant has been given
  #OSS808 Change 27/10/2013
  #Renamed to scores from get_scores

  def scores(questions)
    scores = Hash.new
    scores[:participant] = self # This doesn't appear to be used anywhere
    self.assignment.questionnaires.each do |questionnaire|
      scores[questionnaire.symbol] = Hash.new
      scores[questionnaire.symbol][:assessments] = questionnaire.get_assessments_for(self)
      scores[questionnaire.symbol][:scores] = Score.compute_scores(scores[questionnaire.symbol][:assessments], questions[questionnaire.symbol])
    end
    scores[:total_score] = assignment.compute_total_score(scores)
    
    # In the event that this is a microtask, we need to scale the score accordingly and record the total possible points
    # PS: I don't like the fact that we are doing this here but it is difficult to make it work anywhere else
    if assignment.is_microtask?
      topic = SignUpTopic.find_by_assignment_id(assignment.id)
      if !topic.nil?
        scores[:total_score] *= (topic.micropayment.to_f / 100.to_f)
        scores[:max_pts_available] = topic.micropayment
      end
    end

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

  def get_members
    team.try :participants
  end


  def get_hyperlinks
    team.try :get_hyperlinks
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

  #OSS808 Change 27/10/2013
  #renamed from get_feedback
  
  def feedback
    return FeedbackResponseMap.get_assessments_for(self)      
  end

  #OSS808 Change 27/10/2013
  # Renamed from get_reviews to reviews

  def reviews
    #ACS Always get assessments for a team
    #removed check to see if it is a team assignment
    return TeamReviewResponseMap.get_assessments_for(self.team)
  end

  #OSS808 Change 27/10/2013
  # Renamed to reviews_by_reviewer from get_reviews_by_reviewer

  def reviews_by_reviewer(reviewer)
    if self.assignment.team_assignment?
      return TeamReviewResponseMap.get_reviewer_assessments_for(self.team, reviewer)          
    else
      return ParticipantReviewResponseMap.get_reviewer_assessments_for(self, reviewer)
    end
  end

  #OSS808 Change 27/10/2013
  # Commented the Duplicated Code, already present in assignment_participant.rb

=begin
  def get_reviews_by_reviewer(reviewer)
    if self.assignment.team_assignment?
      return TeamReviewResponseMap.get_reviewer_assessments_for(self.team, reviewer)          
    else
      return ParticipantReviewResponseMap.get_reviewer_assessments_for(self, reviewer)
    end
  end
=end

  #OSS808 Change 27/10/2013
  # Renamed to metareviews from get_metareviews

  def metareviews
    MetareviewResponseMap.get_assessments_for(self)  
  end

  #OSS808 Change 27/10/2013
  #Method renamed to teammate_reviews from get_teammate_reviews
  def teammate_reviews
    TeammateReviewResponseMap.get_assessments_for(self)
  end

  #OSS808 Change 27/10/2013
  #Method renamed to submitted_files from get_submitted_files
  def submitted_files
    files = Array.new
    if(self.directory_num)      
      files = files_in_directory(self.get_path)
    end
    return files
  end

  #OSS808 Change 27/10/2013
  #Method renamed to files_in_directory from get_files
  
  def files_in_directory(directory)
      files_list = Dir[directory + "/*"]
      files = Array.new
      for file in files_list            
        if File.directory?(file) then          
          dir_files = files_in_directory(file)
          dir_files.each{|f| files << f}
        end
        files << file               
      end      
      return files
  end

  #OSS808 Change 28/10/2013
  # Renamed to wiki_submissions from get_wiki_submissions
  def wiki_submissions
    currenttime = Time.now.month.to_s + "/" + Time.now.day.to_s + "/" + Time.now.year.to_s

    #ACS Check if the team count is greater than one(team assignment)
    if self.assignment.max_team_size > 1 and self.assignment.wiki_type.name == "MediaWiki"
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

  #OSS808 Change 27/10/2013
  #Redundant Method - already in participant.rb  and assignment_participant.rb

=begin
  def name
    self.user.name
  end
=end

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
      #now, check to make sure the digital signature is valid, if not raise error
      participant.permission_granted = participant.verify_digital_signature(privateKey)
      participant.save
      raise 'Invalid key' unless participant.permission_granted
    end
  end
  
  # verify the digital signature is valid
  def verify_digital_signature(private_key)
    user.public_key == OpenSSL::PKey::RSA.new(private_key).public_key.to_pem
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

  #OSS808 Change 27/10/2013
  #Could not remove get from method name because get_path method exists in various models like
  #course, assignment, etc and there are dynamic usages of this method

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
      #ACS Get participants irrespective of the number of participants in the team
      #removed check to see if it is a team assignment
        self.team.get_participants.each{
            | member |
            if member.directory_num == nil or member.directory_num < 0
              member.directory_num = self.directory_num
              member.save
            end
        }
    end
  end
  #OSS808 Change 27/10/2013
  #moved from participant.rb

  def get_current_stage
    assignment.try :get_current_stage, topic_id
  end
  alias_method :current_stage, :get_current_stage

  #OSS808 Change 27/10/2013
  #moved from participant.rb

  def get_stage_deadline
    assignment.get_stage_deadline topic_id
  end
  alias_method :stage_deadline, :get_stage_deadline


  #OSS808 Change 27/10/2013
  #moved from participant.rb
  def review_response_maps
    ParticipantReviewResponseMap.find_all_by_reviewee_id_and_reviewed_object_id(id, assignment.id)
  end


  # OSS808 Change 28/10/2013
  # renamed method to course_string from get_course_string
  def course_string
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

    private

  # Use submmit_hyperlink(), remove_hyperlink() instead
  def submitted_hyperlinks=(val)
    write_attribute :submitted_hyperlinks, val
  end

end   #class ends


#OSS808 Change 27/10/2013
#Method commented as it is defined outside the class and also present in superclass, hence redundant
=begin
def get_topic_string
    if topic.nil? or topic.topic_name.empty?
      return "<center>&#8212;</center>"
    end
    return topic.topic_name
  end
=end

