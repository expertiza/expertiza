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
        userAssignments = AssignmentParticipant.find(:all, :conditions =>["user_id = ? ", user_id])
        noCourseAssignments = Array.new
        for ua in userAssignments
            noCA = Assignment.find(:first, :conditions =>["id = ? and course_id is NULL", ua.parent_id])
            if noCA != nil
               noCourseAssignments<< noCA
            end
        end
      return noCourseAssignments
    end
  
  
  def self.getAssignmentsInCourses(courseArray)
    assignmentList = Assignment.find(:all, 
                                     :conditions => ["course_id in (?)", courseArray])
  end
  
  # This method gets all tuples in the Participants table associated
  # with a course in the courseArray and puts them into a hash structure
  # hierarchy (qtype => course => user => score)
  
  
  
  def self.getParticipantEntriesInCourses(courseArray, user_id)
     assignmentList = getAssignmentsInCourses(courseArray)
     independantAssignments = getIndependantAssignments(user_id)
    for iA in independantAssignments
         assignmentList << iA
    end
     questionnaireHash = getParticipantEntriesInAssignmentList(assignmentList)
  end
  
  # This method gets all tuples in the Participants table associated
  # with a specific assignment and puts them into a hash structure
  # hierarchy (qtype => course => user => score).
  
  
  def self.getParticipantEntriesInAssignment(assignmentID)
    assignmentList = Array.new
    assignmentList << Assignment.find(assignmentID)
    questionnaireHash = getParticipantEntriesInAssignmentList(assignmentList)
  end
  
  # This method gets all tuples in the Participants table associated
  # with an assignment in the assignmentList and puts them into a hash 
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
        @revqids = AssignmentQuestionnaire.find(:all, :conditions => ["assignment_id = ?",assgt.id])
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
        
        if (assgt.team_assignment)
          assTeamHash[assgt.id] = "team"
        else
           assTeamHash[assgt.id] = "indie"
        end
    end
    # end of first for
    
   
    participantList = AssignmentParticipant.find(:all,
                                             :select => "id, user_id, parent_id",
                                             :conditions => ["parent_id in (?)", assignmentList])
    #Creating an participant id to [user id, Assignment id] hash
    partAssHash = Hash.new
    for part in participantList
      partAssHash[part.id] = [part.user_id, part.parent_id]
    end
   # csEntries = ComputedScore.find(:all,
    #                             :conditions => ["participant_id in (?)", participantList])
                                 
   
             csEntries = Array.new               
    #####Computation of csEntries
    
    
    ##The next part of the program expects csEntries to be a array of [participant_id, questionnaire_id, total_score] values
    ## The adaptor class given generates the expected csEntries values using the score_cache table
    ## for all assignments, hadling ,metareviews, feedbacks and teammate reviews, participant_id is the same as reviewee_id, questionnaire_id is the one used for this assignment, and total_score is same as score in the score_cache table
    ## for team assignments, we look up team numbers from the score_cache table, find the participants within the team, for each team member make a new csEntry with the respective participant_id, questionnaire_id, and total_score
    ## code :Abhishek

    
   argList = ['MetareviewResponseMap', 'FeedbackResponseMap','TeammateReviewResponseMap']
  
   for assgt in assignmentList
            
            
            
            participants_for_assgt = AssignmentParticipant.find(:all, 
                                                             :conditions =>["parent_id = ? and type =?", assgt.id, 'AssignmentParticipant'])
            fMTEntries = ScoreCache.find(:all, 
                                          :conditions =>["reviewee_id in (?) and object_type in (?)", participants_for_assgt, argList])
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
                   participant_entries = ScoreCache.find(:all, 
                                                    :conditions =>["reviewee_id in (?) and object_type = ?", participants_for_assgt, 'ParticipantReviewResponseMap' ]) 
                   for participant_entry in participant_entries
                  	    csEntry = CsEntriesAdaptor.new
                 	    csEntry.participant_id = participant_entry.reviewee_id
                	    csEntry.questionnaire_id = assQuestionnaires[assgt.id]["Review"]
                	    csEntry.total_score = participant_entry.score
                	    csEntries << csEntry
                   end
            else
                  assignment_teams = Team.find(:all, 
                                             :conditions => ["parent_id = ? and type = ?", assgt.id, 'AssignmentTeam']) 
                  team_entries = ScoreCache.find(:all, 
                                              :conditions =>["reviewee_id in (?) and object_type = ?", assignment_teams, 'TeamReviewResponseMap'])
                  for team_entry in team_entries
                            team_users = TeamsParticipant.find(:all,
                                                :conditions => ["team_id = ?",team_entry.reviewee_id])
                           
                            for team_user in team_users
                                   team_participant = AssignmentParticipant.find(:first, 
                                                                                    :conditions =>["user_id = ? and parent_id = ?", team_user.user_id, assgt.id])
                                   csEntry = CsEntriesAdaptor.new
                                   csEntry.participant_id = team_participant.id        	     
                                   csEntry.questionnaire_id = assQuestionnaires[assgt.id]["Review"]
              	                   csEntry.total_score = team_entry.score
              	                 
              	                   csEntries << csEntry
                            end
             
                   end
   	    end
    end
    #puts "************looking at all the csEntries elements***********"
    #for csEntry in csEntries
    #puts "csEntry -> #{csEntry.participant_id} , #{csEntry.questionnaire_id}, #{csEntry.total_score}"
    #end
    ####################### end of Code Abhishek #############
    #qtype => course => user => score
    
    qtypeHash = Hash.new
    

    for csEntry in csEntries  
    
      qtype = Questionnaire.find(csEntry.questionnaire_id).type.to_s
      courseid = assCourseHash[partAssHash[csEntry.participant_id][1]]
      userid = partAssHash[csEntry.participant_id][0]
      
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
  def self.sortHash(qtypeHash)
    qtypeHash.each { |qtype, courseHash|
       courseHash.each { |course, userScoreHash|
          userScoreSortArray = userScoreHash.sort { |a, b| b[1][0] <=> a[1][0]}
          qtypeHash[qtype][course] = userScoreSortArray
       }       
    }
    qtypeHash
  end
  
  
  
  
  
  
  
  
  # This method takes the sorted computed score hash structure and mines
  # it for personal achievement information.
  def self.extractPersonalAchievements(csHash, courseList, userID)
    # Get all the possible accomplishments from Leaderboard table
    
    accompList = Leaderboard.find(:all,
                                  :select => 'qtype')
    # New hash for courses and accomplishments
    courseAccHash = Hash.new
    # Go through each course-accomplishment combo
    courseList.each { |courseID|
       accompList.each { |accomp| 
       qtypeid = accomp.qtype
       # Make sure there are no nils in the chain
   
       if csHash[qtypeid]

          if csHash[qtypeid][courseID]
             
     
             if csHash[qtypeid][courseID][userID]
               # We found a combo for accomplishment, course, and user
 
                if courseAccHash[courseID] == nil
                   courseAccHash[courseID] = Array.new
                end
                #puts csHash[qtypeid][courseID][userID].join(",")
                # Add an array with accomplishment and score
                courseAccHash[courseID] << [qtypeid, csHash[qtypeid][courseID][userID]]
           	
                
                pp csHash[qtypeid][courseID][userID]
             end
          end
       end
       }
    }

    # Next part is to extract ranking from csHash
    
    # Sort the hash (which changes the structure slightly)
    # NOTE: This changes the original csHash
    csSortHash= Leaderboard.sortHash(csHash)
    
    courseAccomp = Hash.new
    courseAccHash.each { |courseID, accompScoreArray|
      # puts "Processing course #{courseID}"
       accompScoreArray.each { |accompScoreArrayEntry|
        #  pp accompScoreArrayEntry
          
         # puts accompScoreArrayEntry[courseID][idx]
            score = accompScoreArrayEntry[1][0]
            #let me know if you can't understand this part.
            accomp = accompScoreArrayEntry[0]
            userScoreArray = accompScoreArrayEntry[1]
            rank = csSortHash[accomp][courseID].index([userID, userScoreArray])+ 1
            total = csSortHash[accomp][courseID].length
            if courseAccomp[courseID] == nil
               courseAccomp[courseID] = Array.new
            end
            courseAccomp[courseID] << { :accomp => Leaderboard.find_by_qtype(accomp).name,
                                        :score => score,
                                        :rankStr => "#{rank} of #{total}"}
            }
           }
       
   
    courseAccomp
  
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
