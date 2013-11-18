require 'uri'
require 'yaml'

# Code Review: Notice that Participant overloads two different concepts: 
#              contribution and participant (see fields of the participant table).
#              Consider creating a new table called contributions.
class AssignmentParticipant < Participant

  require 'wiki_helper'
  
  belongs_to  :assignment, :class_name => 'Assignment', :foreign_key => 'parent_id' 
  has_many    :review_mappings, :class_name => 'ParticipantReviewResponseMap', :foreign_key => 'reviewee_id'
  has_many    :collusion_cycles
  has_many    :responses, :finder_sql => 'SELECT r.* FROM responses r, response_maps m, participants p WHERE r.map_id = m.id AND m.type = \'ParticipantReviewResponseMap\' AND m.reviewee_id = p.id AND p.id = #{id}'
  belongs_to  :user
  validates_presence_of :handle

  # Returns the average score of one question from all reviews for this user on this assignment as an floating point number
  # Params: question - The Question object to retrieve the scores from
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

  def dir_path
    assignment.try :directory_path
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
    participant == self
  end

  def assign_reviewer(reviewer)
    ParticipantReviewResponseMap.create(:reviewee_id => self.id, :reviewer_id => reviewer.id,
      :reviewed_object_id => assignment.id)
  end

  # Evaluates whether this participant contribution was reviewed by reviewer
  # @param[in] reviewer AssignmentParticipant object 
  def reviewed_by?(reviewer)
    ParticipantReviewResponseMap.count(:conditions => ['reviewee_id = ? && reviewer_id = ? && reviewed_object_id = ?',
                                              self.id, reviewer.id, assignment.id]) > 0
  end

  def has_submissions?
    return ((submitted_files.length > 0) or
            (wiki_submissions.length > 0) or
            (get_hyperlinks_array.length > 0)) 
  end

  # all the participants in this assignment reviewed by this person
   def reviewees
    reviewees = []
    if self.assignment.team_assignment?
      rmaps = ResponseMap.find_all_by_reviewer_id_and_type(self.id,'TeamReviewResponseMap')
      rmaps.each do |rm|
        reviewees.concat(AssignmentTeam.find(rm.reviewee_id).participants)
      end
    else
      rmaps = ResponseMap.find_all_by_reviewer_id_and_type(self.id,'ParticipantReviewResponseMap')
      rmaps.each do |rm|
        reviewees.push(AssignmentParticipant.find(rm.reviewee_id))
      end
    end
    reviewees
  end
  
  # all the participants in this assignment who have reviewed this person
  def get_reviewers
    reviewers = []
      rmaps = ResponseMap.find(:all, :conditions => ["reviewee_id = #{self.team.id} AND type = 'TeamReviewResponseMap'"])
    rmaps.each do |rm|
      reviewers.push(AssignmentParticipant.find(rm.reviewer_id))
    end
    return reviewers  
  end

  #Accessing cycles related code
  def collusion_cycles
    self.collusion_cycles=CollusionCycle.two_node_cycles
    self.collusion_cycles<<CollusionCycle.three_node_cycles
    self.collusion_cycles<<CollusionCycle.four_node_cycles
    similarity_score= CollusionCycle.cycle_similarity_score(self.collusion_cycles)
    deviation_score=CollusionCycle.cycle_deviation_score(self.collusion_cycles)
  end

  def review_score
    review_questionnaire = self.assignment.questionnaires.select {|q| q.type == "ReviewQuestionnaire"}[0]
    assessment = review_questionnaire.get_assessments_for(self)
    (Score.compute_scores(assessment, review_questionnaire.questions)[:avg] / 100.00) * review_questionnaire.max_possible_score.to_f
  end

  # Return scores that this participant has been given
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

    scores
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
       part = CourseParticipant.create(:user_id => self.user_id, :parent_id => course_id)
       return part
    end
  else
      return nil # return nil so we can tell a copy is not made
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
      return "<center>&#8212;</center>".html_safe
    end
  end

  def feedback
    return FeedbackResponseMap.get_assessments_for(self)      
  end


  def reviews
    TeamReviewResponseMap.get_assessments_for(self.team)
  end

  def get_reviews_by_reviewer(reviewer)
    TeamReviewResponseMap.get_reviewer_assessments_for(self.team, reviewer)
  end

  def get_reviews_by_reviewer(reviewer)
    TeamReviewResponseMap.get_reviewer_assessments_for(self.team, reviewer)
  end

  def metareviews
    MetareviewResponseMap.get_assessments_for(self)  
  end


  def teammate_reviews
    TeammateReviewResponseMap.get_assessments_for(self)
  end


  def submitted_files
    files = Array.new
    if(self.directory_num)      
      files = files_in_directory(self.get_path)
    end
    return files
  end


  def files_in_directory(directory)
      files_list = Dir[directory + "/*"]
      files = Array.new
        if File.directory?(directory)
          dir_files = files_in_directory(directory)
          dir_files.each{|f| files << f}
        end
        files << directory
      files
  end


  def wiki_submissions
    currenttime = Time.now.month.to_s + "/" + Time.now.day.to_s + "/" + Time.now.year.to_s

    #ACS Check if the team count is greater than one(team assignment)
    if self.assignment.max_team_size > 1 && self.assignment.wiki_type.name == "MediaWiki"
       submissions = Array.new
       self.team.get_participants.each do |user|
         val = WikiType.review_mediawiki_group(self.assignment.directory_path, current_time, user.handle)
         submissions << val if val != nil
       end if self.team
       submissions
    elsif self.assignment.wiki_type.name == "MediaWiki"
       return WikiType.review_mediawiki(self.assignment.directory_path, current_time, self.handle)
    elsif self.assignment.wiki_type.name == "DocuWiki"
       return WikiType.review_docuwiki(self.assignment.directory_path, current_time, self.handle)
    else
       Array.new
    end
  end

  def team
    AssignmentTeam.get_team(self)
  end
  
  # provide import functionality for Assignment Participants
  # if user does not exist, it will be created and added to this assignment
  def self.import(row,session,id)    
    raise ArgumentError, "No user id has been specified." if row.length < 1
    user = User.find_by_name(row[0])        
    if user == nil
      raise ArgumentError, "The record containing #{row[0]} does not have enough items." if row.length < 4
      attributes = ImportFileHelper::define_attributes(row)
      user = ImportFileHelper::create_new_user(attributes,session)
    end
    raise ImportError, "The assignment with id \""+id.to_s+"\" was not found." if Assignment.find(id) == nil
    if find(:all, {conditions: ['user_id=? && parent_id=?', user.id, id]}).size == 0
          new_part = AssignmentParticipant.create(:user_id => user.id, :parent_id => id)
          new_part.set_handle()
    end             
  end  
  
  # provide export functionality for Assignment Participants
  def self.export(csv,parent_id,options)
     find_all_by_parent_id(parent_id).each do |part|
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
     end
  end
  
  def self.get_export_fields(options)
    fields = ["name","full name","email","role","parent","email on submission","email on review","email on metareview","handle"]
    fields
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
  def self.grant_publishing_rights(private_key, participants)
    participants.each do |participant|
      #now, check to make sure the digital signature is valid, if not raise error
      participant.permission_granted = participant.verify_digital_signature(private_key)
      participant.save
      raise 'Invalid key' unless participant.permission_granted
    end
  end
  
  # verify the digital signature is valid
  def verify_digital_signature(private_key)
    user.public_key == OpenSSL::PKey::RSA.new(private_key).public_key.to_pem
  end
  
  #define a handle for a new participant
  def set_handle
    if self.user.handle == nil or self.user.handle == ""
      self.handle = self.user.name
    elsif AssignmentParticipant.find_all_by_parent_id_and_handle(self.assignment.id, self.user.handle).length > 0
        self.handle = self.user.name
      else
        self.handle = self.user.handle
      end
    self.save!
  end


  def get_path
     self.assignment.get_path + "/"+ self.directory_num.to_s
  end
  
  def update_resubmit_times
    new_submit = ResubmissionTime.new(:resubmitted_at => Time.now.to_s)
    self.resubmission_times << new_submit
  end
  
  def set_student_directory_num
    if self.directory_num.nil? or self.directory_num < 0           
      maxnum = AssignmentParticipant.first(:conditions=>['parent_id = ?',self.parent_id], :order => 'directory_num desc').directory_num
      if maxnum
        dirnum = maxnum + 1
      else
        dirnum = 0
      end
      self.update_attribute('directory_num',dirnum)
      #ACS Get participants irrespective of the number of participants in the team
      #removed check to see if it is a team assignment
        self.team.get_participants.each do | member |
          if member.directory_num == nil or member.directory_num < 0
            member.directory_num = self.directory_num
            member.save
          end
        end
    end
  end

  def get_current_stage
    assignment.try :get_current_stage, topic_id
  end
  alias_method :current_stage, :get_current_stage


  def get_stage_deadline
    assignment.get_stage_deadline topic_id
  end
  alias_method :stage_deadline, :get_stage_deadline


  def review_response_maps
    ParticipantReviewResponseMap.find_all_by_reviewee_id_and_reviewed_object_id(id, assignment.id)
  end


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

end
