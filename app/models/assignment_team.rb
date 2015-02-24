class AssignmentTeam < Team

  belongs_to  :assignment, :class_name => 'Assignment', :foreign_key => 'parent_id'
  has_many    :review_mappings, :class_name => 'TeamReviewResponseMap', :foreign_key => 'reviewee_id'
  has_many :response_maps, foreign_key: :reviewee_id
  has_many :responses, through: :response_maps, foreign_key: :map_id

    # START of contributor methods, shared with AssignmentParticipant

    # Whether this team includes a given participant or not
    def includes?(participant)
      participants.include?(participant)
    end

  def assign_reviewer(reviewer)
    if assignment.has_topics?
      topic_id = self.topic.id
      if topic_id==nil
        raise "this team has not taken any topic"
      end
    end
    assignment = Assignment.find(self.parent_id)
    if assignment==nil
      raise "cannot find this assignment"
    end
    if assignment.varying_rubrics_by_round?
      round = assignment.get_current_round(topic_id) #record round number only for varying rubrics feature
    else
      round=nil
    end
    TeamReviewResponseMap.create(:reviewee_id => self.id, :reviewer_id => reviewer.id,
                                 :reviewed_object_id => assignment.id, :round =>round)
  end

  #for varying rubric feature -Yang
  def reviewed_by_in_round?(reviewer,round)
    return TeamReviewResponseMap.where(reviewee_id:self.id, reviewer_id:reviewer.id, reviewed_object_id:assignment.id, round:round).count()>0
    #return TeamReviewResponseMap.count(:conditions => ['reviewee_id = ? AND reviewer_id = ? AND reviewed_object_id = ? AND round=?',
                                                       #sself.id, reviewer.id, assignment.id, round]) > 0
  end

  # Evaluates whether any contribution by this team was reviewed by reviewer
  # @param[in] reviewer AssignmentParticipant object
  def reviewed_by?(reviewer)
    #TeamReviewResponseMap.count(conditions: ['reviewee_id = ? && reviewer_id = ? && reviewed_object_id = ?',  self.id, reviewer.id, assignment.id]) > 0
    TeamReviewResponseMap.where('reviewee_id = ? && reviewer_id = ? && reviewed_object_id = ?',  self.id, reviewer.id, assignment.id).count > 0
  end

  # Topic picked by the team
  def topic
    team_topic = nil
    participants.each do |participant|
      team_topic = participant.topic
      break if team_topic
    end
    team_topic
  end

  # Whether the team has submitted work or not
  def has_submissions?
    list_of_users = participants;
    list_of_users.each { |participant| return true if participant.has_submissions? }
    false
  end

  def reviewed_contributor?(contributor)
    TeamReviewResponseMap.all(conditions: ['reviewee_id = ? && reviewer_id = ? && reviewed_object_id = ?', contributor.id, self.id, assignment.id]).empty? == false
  end

  # END of contributor methods

  def participants
    participants=Array.new
    users.each {|user|
      participants.push(AssignmentParticipant.where(parent_id:parent_id, user_id:user.id ).first)
    }
    return participants
  end

  def delete
    if read_attribute(:type) == 'AssignmentTeam'
      sign_up = SignedUpUser.find_team_participants(parent_id.to_s).select{|p| p.creator_id == self.id}
      sign_up.each(&:destroy)
    end
    super
  end

  def destroy
    response_maps.each(&:destroy)
    super
  end

  def self.get_first_member(team_id)
    find(team_id).participants.first
  end

  def get_hyperlinks
    links = Array.new

    self.participants.each do |participant|
      puts participant.id
      links+= participant.get_hyperlinks_array
    end

    links
  end

  def get_path
    self.get_participants.first.dir_path
  end

  def get_submitted_files
    self.get_participants.first.submitted_files
  end
  alias_method :submitted_files, :get_submitted_files

  def get_review_map_type
    'TeamReviewResponseMap'
  end

  def self.handle_duplicate(team, name, assignment_id, handle_duplicates)
    return name if team.nil? #no duplicate

    if handle_duplicates == "ignore" #ignore: do not create the new team
      p '>>>setting name to nil ...'
      return nil
    end
    return self.generate_team_name(Assignment.find(assignment_id).name) if handle_duplicates == "rename" #rename: rename new team

    if handle_duplicates == "replace" #replace: delete old team
      team.delete
      return name
    else # handle_duplicates = "insert"
      return nil
    end
    end

    def self.import(row,session,assignment_id,options)
      raise ArgumentError, "Not enough fields on this line" if (row.length < 2 && options[:has_column_names] == "true") || (row.length < 1 && options[:has_column_names] != "true")
      raise ImportError, "The assignment with id \""+assignment_id.to_s+"\" was not found. <a href='/assignment/new'>Create</a> this assignment?" if Assignment.find(assignment_id) == nil

      if options[:has_column_names] == "true"
        name = row[0].to_s.strip
        team = where(["name =? && parent_id =?", name, assignment_id]).first
        team_exists = !team.nil?
        name = handle_duplicate(team, name, assignment_id, options[:handle_dups])
        index = 1
      else
        name = self.generate_team_name(Assignment.find(assignment_id).name)
        index = 0
      end

      # create new team for the team to be inserted
      # do not create new team if we choose 'ignore' or 'insert' duplicate teams
      if name
        team = AssignmentTeam.create_team_and_node(assignment_id)
        team.name = name
        team.save
      end

      # insert team members into team unless team was pre-existing & we ignore duplicate teams
      team.import_team_members(index, row) if !(team_exists && options[:handle_dups] == "ignore")
      end

      def email
        self.get_team_users.first.email
      end

      def get_participant_type
        "AssignmentParticipant"
      end

      def get_parent_model
        "Assignment"
      end

      def fullname
        self.name
      end

      def copy(course_id)
        new_team = CourseTeam.create_team_and_node(course_id)
        new_team.name = name
        new_team.save
        #new_team = CourseTeam.create({:name => self.name, :parent_id => course_id})
        copy_members(new_team)
      end

      def add_participant(assignment_id, user)
        AssignmentParticipant.create(parent_id: assignment_id, user_id: user.id, permission_granted: user.master_permission_granted) if AssignmentParticipant.where(parent_id: assignment_id, user_id:  user.id).first == nil
      end

      def assignment
        Assignment.find(self.parent_id)
      end

      # return a hash of scores that the team has received for the questions
      def get_scores(questions)
        scores = Hash.new
        scores[:team] = self # This doesn't appear to be used anywhere
        assignment.questionnaires.each do |questionnaire|
          scores[questionnaire.symbol] = Hash.new
          scores[questionnaire.symbol][:assessments] = TeamReviewResponseMap.where(reviewee_id: self.id)
          scores[questionnaire.symbol][:scores] = Score.compute_scores(scores[questionnaire.symbol][:assessments], questions[questionnaire.symbol])
        end
        scores[:total_score] = assignment.compute_total_score(scores)
        scores
      end
      alias_method :scores, :get_scores

      def self.get_team(participant) # return nil if this participant doesn't have a team
        teams_users = TeamsUser.where(user_id: participant.user_id)
        return nil if !teams_users
        teams_users.each do |teams_user|
          team = Team.find(teams_user.team_id)
          return team if team.parent_id==participant.parent_id
        end
        nil
      end

      def self.export(csv, parent_id, options)
        current_assignment = Assignment.find(parent_id)
        current_assignment.teams.each do |team|
          tcsv = Array.new
          team_users = Array.new
          tcsv.push(team.name)
          if options["team_name"] == "false"
            team_members = TeamsUser.all(conditions: ['team_id = ?', team.id])
            team_members.each do |user|
              team_users.push(user.name)
              team_users.push(" ")
            end
            tcsv.push(team_users)
          end
          tcsv.push(current_assignment.name)
          csv << tcsv
        end
      end

      def self.get_export_fields(options)
        fields = Array.new
        fields.push("Team Name")
        fields.push("Team members") if options["team_name"] == "false"
        fields.push("Assignment Name")
      end

      def self.create_team_and_node(assignment_id)
        assignment = Assignment.find(assignment_id)
        team_name = Team.generate_team_name(assignment.name)
        team = AssignmentTeam.create(name: team_name, parent_id: assignment_id)
        TeamNode.create(parent_id: assignment_id, node_object_id: team.id)
        team
      end

      #Remove a team given the team id
      def self.remove_team_by_id(id)
        old_team = AssignmentTeam.find(id)
        if old_team != nil
          old_team.destroy
        end
      end

      require './app/models/analytic/assignment_team_analytic'
      include AssignmentTeamAnalytic
    end
