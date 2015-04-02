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

  # This method does a destructive sort on the computed scores hash so
  # that it can be mined for personal achievement information
  def self.sortHash(qTypeHash)
    result = Hash.new
    # Deep-copy of Hash
    result = Marshal.load(Marshal.dump(qTypeHash))

    result.each { |qType, courseHash|
      courseHash.each { |courseId, userScoreHash|
        userScoreSortArray = userScoreHash.sort { |a, b| b[1][0] <=> a[1][0]}
        result[qType][courseId] = userScoreSortArray
      }
    }
    result
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

    csSortedHash = Leaderboard.sortHash(csHash)

    for courseId in courseIdList
      for accomplishment in accomplishmentMap.keys
        # Get score for current questionnaireType/accomplishment, courseId and userId from csHash
        score = csHash.fetch(accomplishment, {}).fetch(courseId, {}).fetch(userId, nil)
        if(score)
          if courseAccomplishmentHash[courseId].nil?
            courseAccomplishmentHash[courseId] = Array.new
          end
          # Calculate rank of current user
          rank = 1 + csSortedHash[accomplishment][courseId].index([userId, score])
          total = csSortedHash[accomplishment][courseId].length

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
