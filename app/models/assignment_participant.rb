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

  belongs_to  :assignment, :class_name => 'Assignment', :foreign_key => 'parent_id'
  has_many    :review_mappings, :class_name => 'ReviewResponseMap', :foreign_key => 'reviewee_id'
  has_many    :quiz_mappings, :class_name => 'QuizResponseMap', :foreign_key => 'reviewee_id'
  has_many :response_maps, foreign_key: 'reviewee_id'
  has_many :participant_review_response_maps, foreign_key: 'reviewee_id'
  has_many :quiz_response_maps, foreign_key: 'reviewee_id'
  has_many :quiz_responses, through: :quiz_response_maps, foreign_key: 'map_id'
  # has_many    :quiz_responses,  :class_name => 'Response', :finder_sql => 'SELECT r.* FROM responses r, response_maps m, participants p WHERE r.map_id = m.id AND m.type = \'QuizResponseMap\' AND m.reviewee_id = p.id AND p.id = #{id}'
    has_many    :collusion_cycles
  # has_many    :responses, :finder_sql => 'SELECT r.* FROM responses r, response_maps m, participants p WHERE r.map_id = m.id AND m.type = \'ReviewResponseMap\' AND m.reviewee_id = p.id AND p.id = #{id}'
    belongs_to  :user
  validates_presence_of :handle

  # Returns the average score of one question from all reviews for this user on this assignment as an floating point number
  # Params: question - The Question object to retrieve the scores from
  def average_question_score(question)
    sum_of_scores = 0
    number_of_scores = 0

    self.response_maps.each do |response_map|
      # TODO There must be a more elegant way of doing this...
      unless response_map.response.empty?
        response_map.response.last.scores.each do |score|
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
      if !response_map.response.empty?  then
        sum_of_scores = sum_of_scores + response_map.response.last.average_score
      end
    end

    (sum_of_scores / self.response_maps.size).to_i
  end

  def average_score_per_assignment(assignment_id)
    return 0 if self.response_maps.size == 0

    sum_of_scores = 0

    self.response_maps.metareview_response_maps.each do |metaresponse_map|
      if !metaresponse_map.response.empty? && response_map == assignment_id then
        sum_of_scores = sum_of_scores + response_map.response.last.average_score
      end
    end

    (sum_of_scores / self.response_maps.size).to_i
  end

  def includes?(participant)
    participant == self
  end

  def assign_reviewer(reviewer)
    team_id = TeamsUser.team_id(self.parent_id, self.user_id)
    ReviewResponseMap.create(:reviewee_id => team_id, :reviewer_id => reviewer.id,
                                        :reviewed_object_id => assignment.id)
  end

  def assign_quiz(contributor,reviewer,topic)
    #using topic_id to find first participant.id.
    teams = SignedUpTeam.where(topic_id: @topic_id)
    teams.each do |team|
      users = TeamsUser.where(team_id: team.id)
      participant_id = Participant.where(user_id: users.first.id, parent_id: @assignment_id).id
      break
    end
    quiz = QuizQuestionnaire.find_by_instructor_id(contributor.id)
    QuizResponseMap.create(:reviewed_object_id => quiz.id,:reviewee_id => contributor.id, :reviewer_id => reviewer.id,
                           :type=>"QuizResponseMap")
  end

  def AssignmentParticipant.find_by_user_id_and_assignment_id(user_id, assignment_id)
    return AssignmentParticipant.where(:user_id=>user_id,:parent_id=>assignment_id).first
  end

  #This method should not be used any more after June 2015 because we have removed ParticipantReveiwResponseMap -Yang
  # Evaluates whether this participant contribution was reviewed by reviewer
  # @param[in] reviewer AssignmentParticipant object
  ##def reviewed_by?(reviewer)
  #  team_id = TeamsUser.team_id(self.parent_id, self.user_id)
  ##  ReviewResponseMap.where(['reviewee_id = ? && reviewer_id = ? && reviewed_object_id = ?', team_id, reviewer.id, assignment.id]).count > 0
  #end

  def quiz_taken_by?(contributor, reviewer)
    quiz_id = QuizQuestionnaire.find_by_instructor_id(contributor.id)
    return QuizResponseMap.where(['reviewee_id = ? AND reviewer_id = ? AND reviewed_object_id = ?',
                                  self.id, reviewer.id, quiz_id]).count > 0
  end

  def has_submissions?
    return ((submitted_files.length > 0) or
            (wiki_submissions.length > 0) or
            (hyperlinks_array.length > 0))
  end

  def has_quiz?
    return !QuizQuestionnaire.find_by_instructor_id(self.id).nil?
  end

  # all the participants in this assignment reviewed by this person
  def reviewees
    reviewees = []
    rmaps = ResponseMap.all(conditions: ["reviewer_id = #{self.id} && type = 'ReviewResponseMap'"])
        rmaps.each { |rm| reviewees.concat(AssignmentTeam.find(rm.reviewee_id).participants) }

    reviewees
  end

  # all the participants in this assignment who have reviewed this person
  def reviewers
    reviewers = []
    rmaps = ResponseMap.where(["reviewee_id = #{self.team.id} AND type = 'ReviewResponseMap'"])
    rmaps.each do |rm|
      reviewers.push(AssignmentParticipant.find(rm.reviewer_id))
    end

    reviewers
  end
 

  # Cycle data structure
  # Each edge of the cycle stores a participant and the score given to the participant by the reviewer.
  # Consider a 3 node cycle: A --> B --> C --> A (A reviewed B; B reviewed C and C reviewed A)
  # For the above cycle, the data structure would be: [[A, SCA], [B, SAB], [C, SCB]], where SCA is the score given by C to A.

  def two_node_cycles
    cycles = []
    self.reviewers.each do |ap|
      if ap.reviewers.include?(self)
        self.reviews_by_reviewer(ap).nil? ? next : s01 = self.reviews_by_reviewer(ap).get_total_score
        ap.reviews_by_reviewer(self).nil? ? next : s10 = ap.reviews_by_reviewer(self).get_total_score
        cycles.push([[self, s01], [ap, s10]])
      end
    end
    cycles
  end


  def three_node_cycles
    cycles = []
    self.reviewers.each do |ap1|
      ap1.reviewers.each do |ap2|
        if ap2.reviewers.include?(self)
          self.reviews_by_reviewer(ap1).nil? ? next : s01 = self.reviews_by_reviewer(ap1).get_total_score
          ap1.reviews_by_reviewer(ap2).nil? ? next : s12 = ap1.reviews_by_reviewer(ap2).get_total_score
          ap2.reviews_by_reviewer(self).nil? ? next : s20 = ap2.reviews_by_reviewer(self).get_total_score
          cycles.push([[self, s01], [ap1, s12], [ap2, s20]])
        end
      end
    end
    cycles
  end

  def four_node_cycles
    cycles = []
    self.reviewers.each do |ap1|
      ap1.reviewers.each do |ap2|
        ap2.reviewers.each do |ap3|
          if ap3.reviewers.include?(self)
            self.reviews_by_reviewer(ap1).nil? ? next : s01 = self.reviews_by_reviewer(ap1).get_total_score
            ap1.reviews_by_reviewer(ap2).nil? ? next : s12 = ap1.reviews_by_reviewer(ap2).get_total_score
            ap2.reviews_by_reviewer(ap3).nil? ? next : s23 = ap2.reviews_by_reviewer(ap3).get_total_score
            ap3.reviews_by_reviewer(self).nil? ? next : s30 = ap3.reviews_by_reviewer(self).get_total_score
            cycles.push([[self, s01], [ap1, s12], [ap2, s23], [ap3, s30]])
          end
        end
      end
    end
    cycles
  end

  # Per cycle
  def cycle_similarity_score(cycle)
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

  # Per cycle
  def cycle_deviation_score(cycle)
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

  def review_score
    review_questionnaire = self.assignment.questionnaires.select {|q| q.type == "ReviewQuestionnaire"}[0]
    assessment = review_questionnaire.get_assessments_for(self)
    (Answer.compute_scores(assessment, review_questionnaire.questions)[:avg] / 100.00) * review_questionnaire.max_possible_score.to_f
  end

  def fullname
    self.user.fullname
  end

  def name
    self.user.name
  end

  # Return scores that this participant has been given
  def scores(questions)
    scores = {}
    scores[:participant] = self
    self.assignment.questionnaires.each do |questionnaire|
      round = AssignmentQuestionnaire.find_by_assignment_id_and_questionnaire_id(self.assignment.id, questionnaire.id).used_in_round
      #create symbol for "varying rubrics" feature -Yang
      if(round!=nil)
        questionnaire_symbol = (questionnaire.symbol.to_s+round.to_s).to_sym
      else
        questionnaire_symbol = questionnaire.symbol
      end

      scores[questionnaire_symbol] = {}

      if round==nil
        scores[questionnaire_symbol][:assessments] = questionnaire.get_assessments_for(self)
      else
        scores[questionnaire_symbol][:assessments] = questionnaire.get_assessments_round_for(self,round)
      end
      scores[questionnaire_symbol][:scores] = Answer.compute_scores(scores[questionnaire_symbol][:assessments], questions[questionnaire_symbol])
    end

    scores[:total_score] = self.assignment.compute_total_score(scores)

    #merge scores[review#] (for each round) to score[review]  -Yang
    if self.assignment.varying_rubrics_by_round?
      review_sym = "review".to_sym
      scores[review_sym] = Hash.new
      scores[review_sym][:assessments] = Array.new
      scores[review_sym][:scores] = Hash.new
      scores[review_sym][:scores][:max] = -999999999
      scores[review_sym][:scores][:min] = 999999999
      scores[review_sym][:scores][:avg] = 0
      total_score = 0
      for i in 1..self.assignment.get_review_rounds
        round_sym = ("review"+i.to_s).to_sym
        if scores[round_sym][:assessments].nil? || scores[round_sym][:assessments].length==0
          next
        end
        length_of_assessments=scores[round_sym][:assessments].length.to_f

        scores[review_sym][:assessments]+=scores[round_sym][:assessments]

        if(scores[round_sym][:scores][:max]!=nil && scores[review_sym][:scores][:max]<scores[round_sym][:scores][:max])
          scores[review_sym][:scores][:max]= scores[round_sym][:scores][:max]
        end
        if(scores[round_sym][:scores][:min]!= nil && scores[review_sym][:scores][:min]>scores[round_sym][:scores][:min])
          scores[review_sym][:scores][:min]= scores[round_sym][:scores][:min]
        end
        if(scores[round_sym][:scores][:avg]!=nil)
          total_score += scores[round_sym][:scores][:avg]*length_of_assessments
        end
      end

      if scores[review_sym][:scores][:max] == -999999999 && scores[review_sym][:scores][:min] == 999999999
               scores[review_sym][:scores][:max] = 0
               scores[review_sym][:scores][:min] = 0
      end

      scores[review_sym][:scores][:avg] = total_score/scores[review_sym][:assessments].length.to_f
    end

    # In the event that this is a microtask, we need to scale the score accordingly and record the total possible points
    # PS: I don't like the fact that we are doing this here but it is difficult to make it work anywhere else
    if assignment.is_microtask?
      topic = SignUpTopic.find_by_assignment_id(assignment.id)
      if !topic.nil?
        scores[:total_score] *= (topic.micropayment.to_f / 100.to_f)
        scores[:max_pts_available] = topic.micropayment
      end
    end

    # for all quiz questionnaires (quizzes) taken by the participant
    quiz_responses = Array.new
    quiz_response_mappings = QuizResponseMap.where(reviewer_id: self.id)
    quiz_response_mappings.each do |qmapping|
      if (qmapping.response)
        quiz_responses << qmapping.response
      end
    end
    #scores[:quiz] = Hash.new
    #scores[:quiz][:assessments] = quiz_responses
    #scores[:quiz][:scores] = Answer.compute_quiz_scores(scores[:quiz][:assessments])

    scores[:total_score] = assignment.compute_total_score(scores)
    #scores[:total_score] += compute_quiz_scores(scores)

    # move lots of calculation from view(_participant.html.erb) to model
    if self.grade
      scores[:total_score] = self.grade
    else
      total_score = scores[:total_score]
      if total_score > 100
        total_score = 100
      end
      scores[:total_score] = total_score
    scores
    end
  end

  def compute_quiz_scores(scores)
    total = 0
    if scores[:quiz][:scores][:avg]
      return scores[:quiz][:scores][:avg] * 100  / 100.to_f
    else
      return 0
    end
    return total
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
    hyperlinks = self.hyperlinks_array
    hyperlinks << hyperlink
    self.submitted_hyperlinks = YAML::dump(hyperlinks)
    self.save
  end

  # Note: This method is not used yet. It is here in the case it will be needed.
  # @exception  If the index does not exist in the array
  def remove_hyperlink(hyperlink_to_delete)
    hyperlinks = self.hyperlinks_array
    hyperlinks.delete(hyperlink_to_delete)
    self.submitted_hyperlinks = YAML::dump(hyperlinks)
    self.save
  end

  def members
    team.try :participants
  end

  def hyperlinks
    team.try(:hyperlinks) || []
  end
 
  def hyperlinks_array
    self.submitted_hyperlinks.blank? ? [] : YAML::load(self.submitted_hyperlinks)
  end


  #Copy this participant to a course
  def copy(course_id)
    part = CourseParticipant.where(user_id: self.user_id, parent_id: course_id).first
    CourseParticipant.create(:user_id => self.user_id, :parent_id => course_id) if part.nil?
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
      return "<center>&#8212;</center>".html_safe
    end
  end

  def feedback
    FeedbackResponseMap.get_assessments_for(self)
  end

  def reviews
    #ACS Always get assessments for a team
    #removed check to see if it is a team assignment
    ReviewResponseMap.get_assessments_for(self.team)
  end

  def reviews_by_reviewer(reviewer)
    ReviewResponseMap.get_reviewer_assessments_for(self.team, reviewer)
  end
  
  # def get_reviews
  #   self.response_maps
  # end


  def quizzes_taken
    QuizResponseMap.get_assessments_for(self)
  end

  def metareviews
    MetareviewResponseMap.get_assessments_for(self)
  end


  def teammate_reviews
    TeammateReviewResponseMap.get_assessments_for(self)
  end

  def bookmark_reviews
    BookmarkRatingResponseMap.get_assessments_for(self)
  end

  def submitted_files
    files(self.path) if self.directory_num
  end

  def files(directory)
    files_list = Dir[directory + "/*"]
    files = Array.new

    files_list.each do |file|
      if File.directory?(file)
        dir_files = files(file)
        dir_files.each{|f| files << f}
      end
      files << file
    end
    files
  end

  def submitted_files()
    files = Array.new
    if(self.directory_num)
      files = files(self.path)
    end
    return files
  end

  def wiki_submissions
    current_time = Time.now.month.to_s + "/" + Time.now.day.to_s + "/" + Time.now.year.to_s

    #ACS Check if the team count is greater than one(team assignment)
    if self.assignment.max_team_size > 1 && self.assignment.wiki_type.name == "MediaWiki"
      submissions = Array.new
      self.team.participants.each do |user|
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
    AssignmentTeam.team(self)
  end

  # provide import functionality for Assignment Participants
  # if user does not exist, it will be created and added to this assignment
  def self.import(row,row_header=nil,session,id)
    raise ArgumentError, "No user id has been specified." if row.length < 1
    user = User.find_by_name(row[0])
    if user == nil
      raise ArgumentError, "The record containing #{row[0]} does not have enough items." if row.length < 4
      attributes = ImportFileHelper::define_attributes(row)
      user = ImportFileHelper::create_new_user(attributes,session)
    end
    raise ImportError, "The assignment with id \""+id.to_s+"\" was not found." if Assignment.find(id) == nil
    if !AssignmentParticipant.exists?(:user_id => user.id, :parent_id => id)
      new_part = AssignmentParticipant.create(:user_id => user.id, :parent_id => id)
      new_part.set_handle()
    end
  end

  # provide export functionality for Assignment Participants
  def self.export(csv,parent_id,options)
    where(parent_id: parent_id).each do |part|
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

  def self.export_fields(options)
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
      elsif AssignmentParticipant.where(parent_id: self.assignment.id, handle: self.user.handle).length > 0
        self.handle = self.user.name
      else
        self.handle = self.user.handle
      end
      self.save!
    end

    def path
      self.assignment.path + "/"+ self.directory_num.to_s
    end

    #zhewei: this is the file path for reviewer uploaded files during peer review
    def review_file_path(response_map_id)
        response_map = ResponseMap.find(response_map_id)
        first_user_id = TeamsUser.where(team_id: response_map.reviewee_id).first.user_id
        participant = Participant.where(parent_id: response_map.reviewed_object_id, user_id: first_user_id).first
        self.assignment.path + "/"+ participant.directory_num.to_s + "_review" + "/" + response_map_id.to_s
    end

    def update_resubmit_times
      new_submit = ResubmissionTime.new(:resubmitted_at => Time.now.to_s)
      self.resubmission_times << new_submit
    end

    def set_student_directory_num
      if self.directory_num.nil? || self.directory_num < 0
        #check all the users in this team, see if they have the direc tory_num in their participants table.
        this_team_has_directory_num = false
        team = self.team
        if team.nil? # this participant does not have a team

        else
          teammate_participants = team.participants
          teammate_participants.each do |teammate_participant|
            if !teammate_participant.directory_num.nil?
              directory_num_for_this_team = teammate_participant.directory_num
              this_team_has_directory_num=true
              self.team.participants.each do | member |
                member.update_attribute('directory_num',directory_num_for_this_team)
              end
            end
          end
        end

        ##only create a new directory num for this team if there is no directory num for this team
        if !this_team_has_directory_num
          max_num = AssignmentParticipant.where(parent_id: self.parent_id).order('directory_num desc').first.directory_num
          dir_num = max_num ? max_num + 1 : 0
          self.update_attribute('directory_num',dir_num)
          #ACS Get participants irrespective of the number of participants in the team
          #removed check to see if it is a team assignment
          self.team.participants.each do | member |
            member.directory_num = self.directory_num
            member.save
          end
        end
      end

      # if current user has directory_num, update the directory num for all the teammates.
      self.team.participants.each do | member |
        member.update_attribute('directory_num',self.directory_num)
      end
    end

    def current_stage
      topic_id = SignedUpTeam.topic_id(self.parent_id, self.user_id)
      assignment.try :get_current_stage, topic_id
    end


    def stage_deadline
      topic_id = SignedUpTeam.topic_id(self.parent_id, self.user_id)
      assignment.stage_deadline topic_id
    end


    def review_response_maps
      participant = Participant.find(id)
      team_id = TeamsUser.team_id(participant.parent_id, participant.user_id)
      ReviewResponseMap.where(reviewee_id: team_id, reviewed_object_id: assignment.id)
    end
  
  end
