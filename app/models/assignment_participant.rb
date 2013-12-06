require 'uri'
require 'yaml'

# Code Review: Notice that Participant overloads two different concepts: 
#              contribution and participant (see fields of the participant table).
#              Consider creating a new table called contributions.
#
# Alias methods exist in this class which append 'get_' to many method names. Use
# the idiomatic ruby method names (without get_)

class AssignmentParticipant < Participant
  require 'wiki_helper'
   #ParticipantReviewResponseMap changed to ParticipantReviewResponse
  belongs_to  :assignment, :class_name => 'Assignment', :foreign_key => 'parent_id'
  has_many    :review_mappings, :class_name => 'ParticipantReviewResponse', :foreign_key => 'reviewee_id'
  has_many    :responses, :finder_sql => 'SELECT r.* FROM responses r,  participants p WHERE r.type = \'ParticipantReviewResponse\' AND r.reviewee_id = p.id AND p.id = #{id}'
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
      ################# I think response_map has to be changed to response_maps #####################
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

  def assign_reviewer(reviewer) #ParticipantReviewResponseMap was changed to ParticipantReviewResponse
    ParticipantReviewResponse.create(:reviewee_id => self.id, :reviewer_id => reviewer.id,
                                        :reviewed_object_id => assignment.id)
  end

  # Evaluates whether this participant contribution was reviewed by reviewer
  # @param[in] reviewer AssignmentParticipant object 
  def reviewed_by?(reviewer)   #ParticipantReviewResponseMap changed to ParticipantReviewResponse
    ParticipantReviewResponse.count(:conditions => ['reviewee_id = ? && reviewer_id = ? && reviewed_object_id = ?',
                                                       self.id, reviewer.id, assignment.id]) > 0
  end

  def has_submissions?
    ((get_submitted_files.length > 0) || (get_wiki_submissions.length > 0) || (get_hyperlinks_array.length > 0))
  end

  # all the participants in this assignment reviewed by this person
  def reviewees
    reviewees = []   #rmaps below has beenchanged to responseMaps
    if self.assignment.team_assignment? #ResponseMap changed to Response, and type = 'TeamReviewResponseMap is being changed  to TeamReviewResponse
      responseMaps = Response.find(:all, conditions: ["reviewer_id = #{self.id} && type = 'TeamReviewResponse'"])
      responseMaps.each { |rm| reviewees.concat(AssignmentTeam.find(rm.reviewee_id).participants) }
    else   #type = 'ParticipantReviewResponseMap is being changed  to ParticipantReviewResponse
      responseMaps = Response.find(:all, :conditions => ["reviewer_id = #{self.id} && type = 'ParticipantReviewResponse'"])
      responseMaps.each {|rm| reviewees.push(AssignmentParticipant.find(rm.reviewee_id))}
    end

    reviewees
  end

  # all the participants in this assignment who have reviewed this person
  def get_reviewers
    reviewers = [] #ResponseMap changed to Response, and type = 'TeamReviewResponseMap is being changed  to TeamReviewResponse
    if self.assignment.team_assignment? && self.team
      responseMaps = Response.find(:all, :conditions => ["reviewee_id = #{self.team.id} AND type = 'TeamReviewResponse'"])
    else #type = 'ParticipantReviewResponseMap is being changed  to ParticipantReviewResponse
      responseMaps = Response.find(:all, :conditions => ["reviewee_id = #{self.id} AND type = 'ParticipantReviewResponse'"])
    end
    responseMaps.each do |rm|
      reviewers.push(AssignmentParticipant.find(rm.reviewer_id))
    end

    reviewers
  end
  alias_method :reviewers, :get_reviewers

  # Cycle data structure
  # Each edge of the cycle stores a participant and the score given to the participant by the reviewer.
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
    cycles
  end
  alias_method :two_node_cycles, :get_two_node_cycles

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
    cycles
  end
  alias_method :three_node_cycles, :get_three_node_cycles

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
    cycles
  end
  alias_method :four_node_cycles, :get_four_node_cycles

  # Per cycle
  def get_cycle_similarity_score(cycle)
    similarity_score = 0.0
    count = 0.0

    0 ... cycle.size-1.each do |pivot|
      pivot_score = cycle[pivot][1]
      similarity_score = similarity_score + (pivot_score - cycle[other][1]).abs
      count = count + 1.0
    end

    similarity_score = similarity_score / count unless count == 0.0
    similarity_score
  end
  alias_method :cycle_similarity_score, :get_cycle_similarity_score

  # Per cycle
  def get_cycle_deviation_score(cycle)
    deviation_score = 0.0
    count = 0.0

    0 ... cycle.size.each do |member|
      participant = AssignmentParticipant.find(cycle[member][0].id)
      total_score = participant.get_review_score
      deviation_score = deviation_score + (total_score - cycle[member][1]).abs
      count = count + 1.0
    end

    deviation_score = deviation_score / count unless count == 0.0
    deviation_score
  end
  alias_method :cycle_deviation_score, :get_cycle_deviation_score

  def review_score
    review_questionnaire = self.assignment.questionnaires.select {|q| q.type == "ReviewQuestionnaire"}[0]
    assessment = review_questionnaire.get_assessments_for(self)
    (Score.compute_scores(assessment, review_questionnaire.questions)[:avg] / 100.00) * review_questionnaire.max_possible_score.to_f
  end

  def fullname
    self.user.fullname
  end

  def name
    self.user.name
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
  def submit_hyperlink(hyperlink)
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
  alias_method :members, :get_members


  def get_hyperlinks
    team.try :get_hyperlinks
  end
  alias_method :hyperlinks, :get_hyperlinks

  def get_hyperlinks_array
    self.submitted_hyperlinks.nil? ? [] : YAML::load(self.submitted_hyperlinks)
  end
  alias_method :hyperlinks_array, :get_hyperlinks_array

  #Copy this participant to a course
  def copy(course_id)
    part = CourseParticipant.find_by_user_id_and_parent_id(self.user_id,course_id)
    CourseParticipant.create(:user_id => self.user_id, :parent_id => course_id) if part.nil?
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
  alias_method :course_string, :get_course_string

  def get_feedback
    FeedbackResponse.get_assessments_for(self)    #FeedbackResponseMap changed to FeedbackResponse
  end
  alias_method :feedback, :get_feedback

  def get_reviews
    #ACS Always get assessments for a team
    #removed check to see if it is a team assignment
    TeamReviewResponse.get_assessments_for(self.team)#TeamReviewResponseMap changed to TeamReviewResponse
  end
  alias_method :reviews, :get_reviews

  def get_reviews_by_reviewer(reviewer)
    TeamReviewResponse.get_reviewer_assessments_for(self.team, reviewer)   # TeamReviewResponseMap  changed to TeamReviewResponseMap
  end
  alias_method :reviews_by_reviewer, :get_reviews_by_reviewer

  def metareviews
    MetareviewResponse.get_assessments_for(self) #MetareviewResponseMap changed to MetareviewResponse
  end


  def teammate_reviews
    TeammateReviewResponse.get_assessments_for(self)  #TeammateReviewResponseMap changed to TeammateReviewResponse
  end

  def get_submitted_files
    files = Array.new
    files = get_files(self.get_path) if self.directory_num
    files
  end
  alias_method :submitted_files, :get_submitted_files

  def get_files(directory)
    files_list = Dir[directory + "/*"]
    files = Array.new

    files_list.each do |file|
      if File.directory?(file)
        dir_files = get_files(file)
        dir_files.each{|f| files << f}
      end
      files << file
    end
    files
  end
  alias_method :files_in_directory, :get_files
  alias_method :files, :get_files

  def get_wiki_submissions
    current_time = Time.now.month.to_s + "/" + Time.now.day.to_s + "/" + Time.now.year.to_s

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
  alias_method :wiki_submissions, :get_wiki_submissions

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
    ["name","full name","email","role","parent","email on submission","email on review","email on metareview","handle"]
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
  alias_method :path, :get_path

  def update_resubmit_times
    new_submit = ResubmissionTime.new(:resubmitted_at => Time.now.to_s)
    self.resubmission_times << new_submit
  end

  def set_student_directory_num
    if self.directory_num.nil? || self.directory_num < 0
      max_num = AssignmentParticipant.find(:first, conditions: ['parent_id = ?', self.parent_id], :order => 'directory_num desc').directory_num
      dir_num = max_num ? max_num + 1 : 0
      self.update_attribute('directory_num',dir_num)
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


  def review_response_maps #ParticipantReviewResponseMap changed to ParticipantReviewResponse
    ParticipantReviewResponse.find_all_by_reviewee_id_and_reviewed_object_id(id, assignment.id)
  end

  def get_topic_string
    return "<center>&#8212;</center>" if topic.nil? or topic.topic_name.empty?
    topic.topic_name
  end
  alias_method :topic_string, :get_topic_string
end
