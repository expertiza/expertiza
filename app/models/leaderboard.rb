# Currently this is a repository for a lot of static class methods.
# Many of the methods were moved to leaderboard_helper.rb and more
# probably should be moved.
class Leaderboard < ActiveRecord::Base

  # This module is not really required, but can be helpful when
  # using the script/console and needing to print hash structures.
  require 'pp'

  # This method gets all the assignments associated with a courses
  # in an array. A course_id of 0 will get assignments not affiliated
  # with a specific course.

  ### This methodreturns unaffiliiated assignments - assignments not affiliated to any course
  def self.getIndependantAssignments(user_id)
    assignmentIds = AssignmentParticipant.where(:user_id => user_id).pluck(:parent_id)
    noCourseAssignments = Assignment.where(:id => assignmentIds, :course_id => nil)
  end


  def self.getAssignmentsInCourses(courseArray)
    assignmentList = Assignment.where(:course_id => courseArray)
  end

  # This method gets all tuples in the Participants table associated
  # hierarchy (qtype => course => user => score)

  def self.getParticipantEntriesInCourses(courseArray, user_id)
    assignmentList = Array.new
    assignmentList = getAssignmentsInCourses(courseArray)
    independantAssignments = getIndependantAssignments(user_id)
    assignmentList.concat(independantAssignments)

    # questionnaireHash = getParticipantEntriesInAssignmentList(assignmentList)
    questionnaireHash = getParticipantsScore(assignmentList)
  end

  # This method gets all tuples in the Participants table associated
  # hierarchy (qtype => course => user => score).


  def self.getParticipantEntriesInAssignment(assignmentID)
    assignmentList = Array.new
    assignmentList << Assignment.find(assignmentID)
    questionnaireHash = getParticipantEntriesInAssignmentList(assignmentList)
  end

  # This method returns the participants score grouped by course, grouped by questionnaire type.
  # End result is a hash (qType => (course => (user => score)))
  def self.getParticipantsScore(assignmentList)
    qTypeHash = Hash.new
    questionnaireResponseTypeHash = {"TeamReviewResponseMap" => "ReviewQuestionnaire",
                                     "MetareviewResponseMap" => "MetareviewQuestionnaire",
                                     "FeedbackResponseMap" => "AuthorFeedbackQuestionnaire",
                                     "TeammateReviewResponseMap" => "TeammateReviewQuestionnaire"}

    # Get all participants of the assignment list
    participantList = AssignmentParticipant.where(:parent_id => assignmentList.pluck(:id)).uniq

    # Get all teams participated in the given assignment list.
    teamList = Team.where("parent_id IN (?) AND type = ?", assignmentList.pluck(:id), 'AssignmentTeam').uniq

    # Get mapping of participant and team with corresponding assignment.
    # "participant" => {participantId => {"self" => <ParticipantRecord>, "assignment" => <AssignmentRecord>}}
    # "team" => {teamId => <AssignmentRecord>}
    assignmentMap = getAssignmentMapping(assignmentList, participantList, teamList)

    # Aggregate total reviewee list
    revieweeList = Array.new
    revieweeList = participantList.pluck(:id)
    revieweeList.concat(teamList.pluck(:id)).uniq!

    # Get scores from ScoreCache for computed reviewee list.
    scores = ScoreCache.where("reviewee_id IN (?) and object_type IN (?)", revieweeList, questionnaireResponseTypeHash.keys)

    for scoreEntry in scores
      revieweeUserIdList = Array.new
      if(assignmentMap["team"].has_key?(scoreEntry.reviewee_id))
        # Reviewee is a team. Actual Reviewee will be users of the team.
        teamUserIds = TeamsUser.where(:team_id => scoreEntry.reviewee_id).pluck(:user_id)
        revieweeUserIdList.concat(teamUserIds)
        courseId = assignmentMap["team"][scoreEntry.reviewee_id].try(:course_id).to_i
      else
        # Reviewee is an individual participant.
        revieweeUserIdList << assignmentMap["participant"][scoreEntry.reviewee_id]["self"].try(:user_id)
        courseId = assignmentMap["participant"][scoreEntry.reviewee_id]["assignment"].try(:course_id).to_i
      end

      questionnaireType = questionnaireResponseTypeHash[scoreEntry.object_type]

      addScoreToResultantHash(qTypeHash, questionnaireType, courseId, revieweeUserIdList, scoreEntry.score)
    end

    qTypeHash
  end

  # This method adds score to all the revieweeUser in qTypeHash.
  # Later, qTypeHash will contain the final computer leaderboard.
  def self.addScoreToResultantHash(qTypeHash, questionnaireType, courseId, revieweeUserIdList, scoreEntryScore)
    if revieweeUserIdList
      # Loop over all the revieweeUserId.
      for revieweeUserId in revieweeUserIdList
        if qTypeHash.fetch(questionnaireType, {}).fetch(courseId, {}).fetch(revieweeUserId, nil).nil?
          userHash = Hash.new
          userHash[revieweeUserId] = [scoreEntryScore, 1]

          if qTypeHash.fetch(questionnaireType, {}).fetch(courseId, nil).nil?
            if qTypeHash.fetch(questionnaireType, nil).nil?
              courseHash = Hash.new
              courseHash[courseId] = userHash

              qTypeHash[questionnaireType] = courseHash
            end

            qTypeHash[questionnaireType][courseId] = userHash
          end

          qTypeHash[questionnaireType][courseId][revieweeUserId] = [scoreEntryScore, 1]
        else
          # RevieweeUserId exist in qTypeHash. Update score.
          currentUserScore = qTypeHash[questionnaireType][courseId][revieweeUserId]
          currentTotalScore = currentUserScore[0] * currentUserScore[1]
          currentUserScore[1] += 1
          currentUserScore[0] = (currentTotalScore + scoreEntryScore) / currentUserScore[1]
        end
      end
    end
  end

  # This method creates a mapping of participant and team with corresponding assignment.
  # "participant" => {participantId => {"self" => <ParticipantRecord>, "assignment" => <AssignmentRecord>}}
  # "team" => {teamId => <AssignmentRecord>}
  def self.getAssignmentMapping(assignmentList, participantList, teamList)
    resultHash = {"participant" => {}, "team" => {}}
    assignmentHash = Hash.new
    # Hash all the assignments for later fetching them by assignment.id
    for assignment in assignmentList
      assignmentHash[assignment.id] = assignment
    end
    # Loop over all the participants to get corresponding assignment by parent_id
    for participant in participantList
      resultHash["participant"][participant.id] = Hash.new
      resultHash["participant"][participant.id]["self"] = participant
      resultHash["participant"][participant.id]["assignment"] = assignmentHash[participant.parent_id]
    end
    # Loop over all the teams to get corresponding assignment by parent_id
    for team in teamList
      resultHash["team"][team.id] = assignmentHash[team.parent_id]
    end

    resultHash
  end

  # This method gets all tuples in the Participants table associated
  # structure hierarchy (qtype => course => user => score).
  def self.getParticipantEntriesInAssignmentList(assignmentList)

    #Creating an assignment id to course id hash
    assCourseHash = Hash.new
    assTeamHash = Hash.new
    assQuestionnaires = Hash.new

    for assgt in assignmentList

      if assgt.course_id != nil
        assCourseHash[assgt.id] = assgt.course_id
      else
        assCourseHash[assgt.id] = 0
      end
      @revqids = []
      differentQuestionnaires = Hash.new
      @revqids = AssignmentQuestionnaire.where(["assignment_id = ?",assgt.id])
      @revqids.each do |rqid|
        rtype = Questionnaire.find(rqid.questionnaire_id).type
        if( rtype == 'ReviewQuestionnaire')


          differentQuestionnaires["Review"] = rqid.questionnaire_id

        elsif( rtype == 'MetareviewQuestionnaire')

          differentQuestionnaires["Metareview"] = rqid.questionnaire_id
        elsif( rtype == 'AuthorFeedbackQuestionnaire')
          differentQuestionnaires["AuthorFeedback"] = rqid.questionnaire_id

        elsif( rtype == 'TeammateReviewQuestionnaire')
          differentQuestionnaires["Teamreview"] = rqid.questionnaire_id
        end # end of elsif block
      end # end of each.do block

      assQuestionnaires[assgt.id] = differentQuestionnaires

      #ACS Everything is a team now
      #removed check to see if it is a team assignment
      assTeamHash[assgt.id] = "team"
    end
    # end of first for


    participantList = AssignmentParticipant.select("id, user_id, parent_id").where(parent_id: assignmentList.pluck(:id))
    #Creating an participant id to [user id, Assignment id] hash
    partAssHash = Hash.new
    participantList.find_each do |part|
      partAssHash[part.id] = [part.user_id, part.parent_id]
    end

    csEntries = Array.new
    #####Computation of csEntries


    ##The next part of the program expects csEntries to be a array of 
    # [participant_id, questionnaire_id, total_score] values.
    # The adaptor class given generates the expected csEntries values using 
    # the score_cache table for all assignments.
    # Handles metareviews, feedbacks and teammate reviews.
    # Participant_id is the same as reviewee_id.
    # Questionnaire_id is the one used for this assignment.
    # Total_score is same as score in the score_cache table.
    # for team assignments, we look up team numbers from the score_cache table, 
    # find the participants within the team.
    # for each team member make a new csEntry with the respective participant_id, 
    # questionnaire_id, and total_score
    ## code :Abhishek


    argList = ['MetareviewResponseMap', 'FeedbackResponseMap','TeammateReviewResponseMap']

    for assgt in assignmentList



      participants_for_assgt = AssignmentParticipant.where("parent_id = ? and type =?", assgt.id, 'AssignmentParticipant').pluck(:id)
      fMTEntries = ScoreCache.where("reviewee_id in (?) and object_type in (?)", participants_for_assgt, argList)
      for fMTEntry in fMTEntries
        csEntry = CsEntriesAdaptor.new
        csEntry.participant_id = fMTEntry.reviewee_id
        if (fMTEntry.object_type == 'FeedbackResponseMap')
          csEntry.questionnaire_id = assQuestionnaires[assgt.id]["AuthorFeedback"]
        elsif (fMTEntry.object_type == 'MetareviewResponseMap')
          csEntry.questionnaire_id = assQuestionnaires[assgt.id]["Metareview"]
        elsif (fMTEntry.object_type == 'TeammateReviewResponseMap')

          csEntry.questionnaire_id = assQuestionnaires[assgt.id]["Teamreview"]
        end
        csEntry.total_score = fMTEntry.score
        csEntries << csEntry
      end
      ######## done with metareviews and feedbacksfor this assgt##############
      ##########now putting stuff in reviews based on if the assignment is a team assignment or not###################
      if assTeamHash[assgt.id] == "indie"
        participant_entries = ScoreCache.where(["reviewee_id in (?) and object_type = ?", participants_for_assgt, 'ParticipantReviewResponseMap' ])
        for participant_entry in participant_entries
          csEntry = CsEntriesAdaptor.new
          csEntry.participant_id = participant_entry.reviewee_id
          csEntry.questionnaire_id = assQuestionnaires[assgt.id]["Review"]
          csEntry.total_score = participant_entry.score
          csEntries << csEntry
        end
      else
        assignment_teams = Team.where("parent_id = ? and type = ?", assgt.id, 'AssignmentTeam')
        team_entries = ScoreCache.where("reviewee_id in (?) and object_type = ?", assignment_teams.pluck(:id), 'TeamReviewResponseMap')
        team_entries.each do |team_entry|
          team_users = TeamsUser.where(["team_id = ?",team_entry.reviewee_id])

          for team_user in team_users
            team_participant = AssignmentParticipant.where(["user_id = ? and parent_id = ?", team_user.user_id, assgt.id]).first
            csEntry = CsEntriesAdaptor.new
            csEntry.participant_id = team_participant.try :id
            csEntry.questionnaire_id = assQuestionnaires[assgt.id]["Review"]
            csEntry.total_score = team_entry.score

            csEntries << csEntry
          end

        end
      end
    end

    qtypeHash = Hash.new

    csEntries.each do |csEntry|
      qtype = Questionnaire.find(csEntry.questionnaire_id).type.to_s if csEntry.questionnaire_id
      courseid = assCourseHash[partAssHash[csEntry.participant_id].try(:[], 1)]
      userid = partAssHash[csEntry.participant_id].try(:first)

      addEntryToCSHash(qtypeHash, qtype, userid, csEntry, courseid)
    end

    qtypeHash
  end

  # This method adds an entry from the Computed_Scores table into a hash
  # structure that is used to in creating the leaderboards.
  def self.addEntryToCSHash(qtypeHash, qtype, userid, csEntry, courseid)
    #If there IS NOT any course for the particular course type
    if qtypeHash[qtype] == nil
      partHash = Hash.new
      partHash[userid] = [csEntry.total_score, 1]
      courseHash = Hash.new
      courseHash[courseid] = partHash
      qtypeHash[qtype] = courseHash
    else
      #There IS at least one course under the particular qtype
      #If the particular course IS NOT present in existing course hash
      if qtypeHash[qtype][courseid] == nil
        courseHash = qtypeHash[qtype]
        partHash = Hash.new
        partHash[userid] = [csEntry.total_score, 1]
        courseHash[courseid] = partHash
        qtypeHash[qtype] = courseHash
      else
        #The particular course is present
        #If the particular user IS NOT present in the existing user hash
        if qtypeHash[qtype][courseid][userid] == nil
          partHash = qtypeHash[qtype][courseid]
          partHash[userid] = [csEntry.total_score, 1]
          qtypeHash[qtype][courseid] = partHash
        else
          #User is present, update score
          current_score = qtypeHash[qtype][courseid][userid][0]
          count = qtypeHash[qtype][courseid][userid][1]
          final_score = ((current_score * count) + csEntry.total_score) / (count + 1)
          count +=(1)
          qtypeHash[qtype][courseid][userid] = [final_score, count]
        end
      end
    end
    if qtypeHash[qtype][courseid][userid] == nil
      partHash[userid] = [csEntry.total_score, 1]
      courseHash[courseid] = partHash
      qtypeHash[qtype] = courseHash
    end
  end

  # This method does a destructive sort on the computed scores hash so
  # that it can be mined for personal achievement information
  def self.sortHash(qTypeHash)
    qTypeHash.each { |qType, courseHash|
      courseHash.each { |courseId, userScoreHash|
        userScoreSortArray = userScoreHash.sort { |a, b| b[1][0] <=> a[1][0]}
        qTypeHash[qType][courseId] = userScoreSortArray
      }
    }
    qTypeHash
  end

  # This method takes the sorted computed score hash structure and mines
  # it for personal achievement information.
  def self.extractPersonalAchievements(csHash, courseIdList, userId)
    # Get all the possible accomplishments from Leaderboard table
    leaderboardRecords = Leaderboard.all()
    courseAccomplishmentHash = Hash.new
    accomplishmentMap = Hash.new

    # Create map of accomplishment with its name
    for leaderboardRecord in leaderboardRecords
      accomplishmentMap[leaderboardRecord.qtype] = leaderboardRecord.name
    end

    for courseId in courseIdList
      for accomplishment in accomplishmentMap.keys
        # Get score for current questionnaireType/accomplishment, courseId and userId from csHash
        score = csHash.fetch(accomplishment, {}).fetch(courseId, {}).fetch(userId, nil)
        if(score)
          if courseAccomplishmentHash[courseId].nil?
            courseAccomplishmentHash[courseId] = Array.new
          end
          # Calculate rank of current user
          rank = 1 + csHash[accomplishment][courseId].keys.index(userId)
          total = csHash[accomplishment][courseId].length

          courseAccomplishmentHash[courseId] << {:accomp => accomplishmentMap[accomplishment],
                                                 :score => score[0],
                                                 :rankStr => "#{rank} of #{total}"
          }
        end
      end
    end
    courseAccomplishmentHash
  end

  # Returns string for Top N Leaderboard Heading or accomplishments entry
  def self.leaderboardHeading(qtypeid)
    ltEntry = Leaderboard.find_by_qtype(qtypeid)
    if ltEntry
      ltEntry.name
    else
      "No Entry"
    end
  end

end
