module LeaderboardHelper
  
  # This method gets the name for a course. If the course id
  # provided is 0, that indicates an assignment that is not
  # associated with a course, and the course name provided
  # is "Unaffiliated Assignments"
  def self.getCourseName(courseID)
    if courseID == 0
       courseName = "Unaffiliated Assignments"
    else
       courseName = Course.find(courseID).name
   end
   courseName   
  end
    
  # This method converts the questionnaire_type to a
  # sensible string for the Leaderboard table. 
  def self.getAchieveName(qtype)
    achieveName = Leaderboard.find(:first , :conditions =>[ "qtype like ?",qtype]).name
    
  end  
  
  # This method gets the name for an assignment. If for some unexpected
  # reason the assignment id does not exist, the string "Unnamed Assignment"
  # is returned.
  def self.getAssignmentName(assignmentID)
    if !assignmentID or assignmentID == 0
      assignmentName = "Unnamed Assignment"
    else
      assignmentName = Assignment.find(assignmentID).name
    end
    assignmentName
  end
  
  # Get the name of the user, honoring the privacy settings.
  # If the requesterID and userID are the same (the student querying is
  # the person on the leaderboard), a "You!" is displayed.
  # If the requesterID is a TA, instructor, or admin, the privacy
  # setting is disregarded.
  def self.getUserName(requesterID, userID)
    user = User.find(userID)
    instructor = userIsInstructor?(requesterID)
    if user.leaderboard_privacy and requesterID != userID and !instructor
      userName = "*****"
    elsif requesterID == userID
      userName = "You!"
    else
      userName = user.fullname
    end
  end
  
  # Identify whether user is considered instructor
  def self.userIsInstructor?(userID)
    # For now, we'll consider Instructors, Admins, Super-Admins, and TAs as instructors
    instructorRoles = Array.new
    instructorRoles << Role.find_by_name("Instructor").id
    instructorRoles << Role.find_by_name("Administrator").id
    instructorRoles << Role.find_by_name("Super-Administrator").id
    instructorRoles << Role.find_by_name("Teaching Assistant").id
    user = User.find(userID)
    instructor = false
    if instructorRoles.index(user.role_id)
      instructor = true
    end
    instructor
  end
  
  # Returns list of course ids in which the student has an assignment
  def self.studentInWhichCourses(userid)
    # Get all entries in Participant table for user
    assignPartList = AssignmentParticipant.find(:all, :conditions =>["user_id =?",userid])
    @courseList = Array.new
    
    for participantEntry in assignPartList

## get the ass in quesstion, get the course in question
    assgt = Assignment.find(participantEntry.parent_id)
    if assgt.course_id == nil
        @courseList << 0
      else
       @courseList << assgt.course_id
     end
    end
    
    @courseList.uniq!
  
    @courseList
  end
  
  # This methods gets all the courses that an instructor has been assigned.
  # This method assumes the instructor_id in the Courses table indicates
  # the courses an instructor is managing.
  def self.instructorCourses(userid)
    courseTuples = Course.find(:all,
                               :conditions => ['instructor_id = ?', userid])
                               
    @courseList = Array.new
    courseTuples.each { |course| @courseList << course.id }
    @courseList
  end
  
  # This method gets the display data needed to show the Top 3 leaderboard
  def self.getTop3Leaderboards(userid, assignmentid)
    courseList = LeaderboardHelper.studentInWhichCourses(userid)
    csHash = Leaderboard.getParticipantEntriesInAssignment(assignmentid)
    csHash = Leaderboard.sortHash(csHash)
    
    # Setup top 3 leaderboards for easier consumption by view
    top3LeaderBoards = Array.new
    csHash.each_pair{|qtype, courseHash|
       courseHash.each_pair{|course, userGradeArray|
          assignmentName = LeaderboardHelper.getAssignmentName(assignmentid)
          achieveName = LeaderboardHelper.getAchieveName(qtype)
          leaderboardHash = Hash.new
          leaderboardHash = {:achievement => achieveName,
                             :courseName => assignmentName,
                             :sortedGrades => userGradeArray}
          top3LeaderBoards << leaderboardHash
       }
    }
    top3LeaderBoards
  end
  
  # This method is only provided for diagnostic purposes. It can be executed from
  # script/console to see what's in the Computed Scores table, in case there is
  # a concern about accuracy of leaderboard results.
  def self.dumpCSTable
    @expList = Array.new
    @csEntries = ComputedScore.find(:all)
    @csEntries.each { |csEntry|
    participant = AssignmentParticipant.find(csEntry.participant_id)
    questionnaire = Questionnaire.find(csEntry.questionnaire_id)

       @expList << {:userName => participant.user.name,
                    :assignName => participant.assignment.name,
                    :courseID => participant.assignment.course.id,
                    :instructorName => questionnaire.instructor.name,
                    :qtypeName => questionnaire.qtype,
                    :totalScore => csEntry.total_score}
    }
    @expList
  end
  
end
