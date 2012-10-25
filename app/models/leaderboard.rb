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
  def self.get_independent_assignments(user_id)
        user_assignments = AssignmentParticipant.find(:all, :conditions =>["user_id = ? ", user_id])
        no_course_assignments = Array.new
        for user_assignment in user_assignments
            no_course_assignment = Assignment.find(:first, :conditions =>["id = ? and course_id is NULL", user_assignment.parent_id])
            if no_course_assignment != nil
               no_course_assignments<< no_course_assignment
            end
        end
      return no_course_assignments
    end
  
  
  def self.get_assignments_in_courses(course_array)
    assignment_list = Assignment.find(:all,
                                     :conditions => ["course_id in (?)", course_array])
  end
  
  # This method gets all tuples in the Participants table associated
  # with a course in the course_array and puts them into a hash structure
  # hierarchy (qtype => course => user => score)
  
  
  
  def self.get_participant_entries_in_courses(courseArray, user_id)
     assignment_list = get_assignments_in_courses(courseArray)
     independent_assignments = get_independent_assignments(user_id)
    for independent_assignment in independent_assignments
         assignment_list << independent_assignment
    end
     questionnaire_hash = get_participant_entries_in_assignment_list(assignment_list)
  end
  
  # This method gets all tuples in the Participants table associated
  # with a specific assignment and puts them into a hash structure
  # hierarchy (qtype => course => user => score).
  
  
  def self.get_participant_entries_in_assignment(assignment_id)
    assignment_list = Array.new
    assignment_list << Assignment.find(assignment_id)
    questionnaire_hash = get_participant_entries_in_assignment_list(assignment_list)
  end
  
  # This method gets all tuples in the Participants table associated
  # with an assignment in the assignment_list and puts them into a hash
  # structure hierarchy (qtype => course => user => score).
  def self.get_participant_entries_in_assignment_list(assignment_list)

    #Creating an assignment id to course id hash
    ass_course_hash = Hash.new
    ass_team_hash = Hash.new
    ass_questionnaires = Hash.new
  
    for assgt in assignment_list
        
        if assgt.course_id != nil
             ass_course_hash[assgt.id] = assgt.course_id
        else
             ass_course_hash[assgt.id] = 0
        end

        ass_questionnaires[assgt.id] = get_different_questionnaires(assgt)
        
        if (assgt.team_assignment)
          ass_team_hash[assgt.id] = "team"
        else
           ass_team_hash[assgt.id] = "indie"
        end
    end
    # end of first for
    
   
    participant_list = AssignmentParticipant.find(:all,
                                             :select => "id, user_id, parent_id",
                                             :conditions => ["parent_id in (?)", assignment_list])
    #Creating an participant id to [user id, Assignment id] hash
    part_ass_hash = Hash.new
    for participant in participant_list
      part_ass_hash[participant.id] = [participant.user_id, participant.parent_id]
    end
   # cs_entries = ComputedScore.find(:all,
    #                             :conditions => ["participant_id in (?)", participant_list])
                                 
   
             cs_entries = Array.new
    #####Computation of cs_entries
    
    
    ##The next part of the program expects cs_entries to be a array of [participant_id, questionnaire_id, total_score] values
    ## The adaptor class given generates the expected cs_entries values using the score_cache table
    ## for all assignments, hadling ,metareviews, feedbacks and teammate reviews, participant_id is the same as reviewee_id, questionnaire_id is the one used for this assignment, and total_score is same as score in the score_cache table
    ## for team assignments, we look up team numbers from the score_cache table, find the participants within the team, for each team member make a new cs_entry with the respective participant_id, questionnaire_id, and total_score
    ## code :Abhishek

    
   arg_list = ['MetareviewResponseMap', 'FeedbackResponseMap','TeammateReviewResponseMap']
  
   for assgt in assignment_list
            
            
            
      participants_for_assgt = AssignmentParticipant.find(:all,
                                                       :conditions =>["parent_id = ? and type =?", assgt.id, 'AssignmentParticipant'])

      cs_entries = cs_entries + add_cs_entries_from_fmt_entries(arg_list, ass_questionnaires, assgt, participants_for_assgt)

   	######## done with metareviews and feedbacksfor this assgt##############
   	##########now putting stuff in reviews based on if the assignment is a team assignment or not###################
   	    if ass_team_hash[assgt.id] == "indie"
                   participant_entries = ScoreCache.find(:all, 
                                                    :conditions =>["reviewee_id in (?) and object_type = ?", participants_for_assgt, 'ParticipantReviewResponseMap' ]) 
                   for participant_entry in participant_entries
                  	    cs_entry = CsEntriesAdaptor.new
                 	    cs_entry.participant_id = participant_entry.reviewee_id
                	    cs_entry.questionnaire_id = ass_questionnaires[assgt.id]["Review"]
                	    cs_entry.total_score = participant_entry.score
                	    cs_entries << cs_entry
                   end
            else
                  assignment_teams = Team.find(:all, 
                                             :conditions => ["parent_id = ? and type = ?", assgt.id, 'AssignmentTeam']) 
                  team_entries = ScoreCache.find(:all, 
                                              :conditions =>["reviewee_id in (?) and object_type = ?", assignment_teams, 'TeamReviewResponseMap'])
                  for team_entry in team_entries
                            team_users = TeamsUser.find(:all, 
                                                :conditions => ["team_id = ?",team_entry.reviewee_id])
                           
                            for team_user in team_users
                                   team_participant = AssignmentParticipant.find(:first, 
                                                                                    :conditions =>["user_id = ? and parent_id = ?", team_user.user_id, assgt.id])
                                   cs_entry = CsEntriesAdaptor.new
                                   cs_entry.participant_id = team_participant.id
                                   cs_entry.questionnaire_id = ass_questionnaires[assgt.id]["Review"]
              	                   cs_entry.total_score = team_entry.score
              	                 
              	                   cs_entries << cs_entry
                            end
             
                   end
   	    end
    end
    #puts "************looking at all the cs_entries elements***********"
    #for cs_entry in cs_entries
    #puts "cs_entry -> #{cs_entry.participant_id} , #{cs_entry.questionnaire_id}, #{cs_entry.total_score}"
    #end
    ####################### end of Code Abhishek #############
    #qtype => course => user => score
    
    qtype_hash = Hash.new
    

    for cs_entry in cs_entries
    
      qtype = Questionnaire.find(cs_entry.questionnaire_id).type.to_s
      course_id = ass_course_hash[part_ass_hash[cs_entry.participant_id][1]]
      user_id = part_ass_hash[cs_entry.participant_id][0]
      
      add_entry_to_cs_hash(qtype_hash, qtype, user_id, cs_entry, course_id)
    end 
 
   qtype_hash
  end

  def self.add_cs_entries_from_fmt_entries(arg_list, ass_questionnaires, assgt, participants_for_assgt)
    cs_entries = []
    fmt_entries = ScoreCache.find(:all,
                                  :conditions => ["reviewee_id in (?) and object_type in (?)", participants_for_assgt, arg_list])
    for fmt_entry in fmt_entries
      cs_entry = CsEntriesAdaptor.new
      cs_entry.participant_id = fmt_entry.reviewee_id
      if (fmt_entry.object_type == 'FeedbackResponseMap')
        cs_entry.questionnaire_id = ass_questionnaires[assgt.id]["AuthorFeedback"]
      elsif (fmt_entry.object_type == 'MetareviewResponseMap')
        cs_entry.questionnaire_id = ass_questionnaires[assgt.id]["Metareview"]
      elsif (fmt_entry.object_type == 'TeammateReviewResponseMap')
        cs_entry.questionnaire_id = ass_questionnaires[assgt.id]["Teamreview"]
      end
      cs_entry.total_score = fmt_entry.score
      cs_entries << cs_entry
    end
    cs_entries
  end

  def self.get_different_questionnaires(assgt)
    @review_ques_ids = []
    different_questionnaires = Hash.new
    @review_ques_ids = AssignmentQuestionnaire.find(:all, :conditions => ["assignment_id = ?", assgt.id])
    @review_ques_ids.each do |review_ques_id|
      rtype = Questionnaire.find(review_ques_id.questionnaire_id).type
      if (rtype == 'ReviewQuestionnaire')

        different_questionnaires["Review"] = review_ques_id.questionnaire_id

      elsif (rtype == 'MetareviewQuestionnaire')

        different_questionnaires["Metareview"] = review_ques_id.questionnaire_id
      elsif (rtype == 'AuthorFeedbackQuestionnaire')
        different_questionnaires["AuthorFeedback"] = review_ques_id.questionnaire_id

      elsif (rtype == 'TeammateReviewQuestionnaire')
        different_questionnaires["Teamreview"] = review_ques_id.questionnaire_id
      end # end of elsif block
    end
    different_questionnaires
  end

  # This method adds an entry from the Computed_Scores table into a hash
  # structure that is used to in creating the leaderboards.
  def self.add_entry_to_cs_hash(qtype_hash, qtype, userid, cs_entry, courseid)
    #If there IS NOT any course for the particular course type
    if qtype_hash[qtype] == nil
      part_hash = Hash.new
      part_hash[userid] = [cs_entry.total_score, 1]
      course_hash = Hash.new
      course_hash[courseid] = part_hash
      qtype_hash[qtype] = course_hash
    else
      #There IS at least one course under the particular qtype
      #If the particular course IS NOT present in existing course hash
      if qtype_hash[qtype][courseid] == nil
        course_hash = qtype_hash[qtype]
        part_hash = Hash.new
        part_hash[userid] = [cs_entry.total_score, 1]
        course_hash[courseid] = part_hash
        qtype_hash[qtype] = course_hash
      else
        #The particular course is present  
        #If the particular user IS NOT present in the existing user hash
        if qtype_hash[qtype][courseid][userid] == nil
          part_hash = qtype_hash[qtype][courseid]
          part_hash[userid] = [cs_entry.total_score, 1]
          qtype_hash[qtype][courseid] = part_hash
        else
          #User is present, update score
          current_score = qtype_hash[qtype][courseid][userid][0]
          count = qtype_hash[qtype][courseid][userid][1]
          final_score = ((current_score * count) + cs_entry.total_score) / (count + 1)
          count +=(1)
          qtype_hash[qtype][courseid][userid] = [final_score, count]
        end
      end
    end
    if qtype_hash[qtype][courseid][userid] == nil
      part_hash[userid] = [cs_entry.total_score, 1]
      course_hash[courseid] = part_hash
      qtype_hash[qtype] = course_hash
    end
  end
  
  # This method does a destructive sort on the computed scores hash so
  # that it can be mined for personal achievement information
  def self.sort_hash(qtype_hash)
    qtype_hash.each { |qtype, course_hash|
       course_hash.each { |course, user_score_hash|
          user_score_sort_array = user_score_hash.sort { |a, b| b[1][0] <=> a[1][0]}
          qtype_hash[qtype][course] = user_score_sort_array
       }       
    }
    qtype_hash
  end
  

  # This method takes the sorted computed score hash structure and mines
  # it for personal achievement information.
  def self.extract_personal_achievements(cs_hash, course_list, user_ID)
    # Get all the possible accomplishments from Leaderboard table
    
    accomp_list = Leaderboard.find(:all,
                                  :select => 'qtype')
    # New hash for courses and accomplishments
    course_acc_hash = Hash.new
    # Go through each course-accomplishment combo
    course_list.each { |course_ID|
       accomp_list.each { |accomp|
       qtype_id = accomp.qtype
       # Make sure there are no nils in the chain
   
       if cs_hash[qtype_id]

          if cs_hash[qtype_id][course_ID]
             
     
             if cs_hash[qtype_id][course_ID][user_ID]
               # We found a combo for accomplishment, course, and user
 
                if course_acc_hash[course_ID] == nil
                   course_acc_hash[course_ID] = Array.new
                end
                #puts cs_hash[qtype_id][course_ID][user_ID].join(",")
                # Add an array with accomplishment and score
                course_acc_hash[course_ID] << [qtype_id, cs_hash[qtype_id][course_ID][user_ID]]
           	
                
                pp cs_hash[qtype_id][course_ID][user_ID]
             end
          end
       end
       }
    }

    # Next part is to extract ranking from cs_hash
    
    # Sort the hash (which changes the structure slightly)
    # NOTE: This changes the original cs_hash
    cs_sort_hash= Leaderboard.sort_hash(cs_hash)
    
    course_accomp = Hash.new
    course_acc_hash.each { |course_ID, accomp_score_array|
      # puts "Processing course #{course_ID}"
       accomp_score_array.each { |accomp_score_array_entry|
        #  pp accomp_score_array_entry
          
         # puts accomp_score_array_entry[course_ID][idx]
            score = accomp_score_array_entry[1][0]
            #let me know if you can't understand this part.
            accomp = accomp_score_array_entry[0]
            user_score_array = accomp_score_array_entry[1]
            rank = cs_sort_hash[accomp][course_ID].index([user_ID, user_score_array])+ 1
            total = cs_sort_hash[accomp][course_ID].length
            if course_accomp[course_ID] == nil
               course_accomp[course_ID] = Array.new
            end
            course_accomp[course_ID] << { :accomp => Leaderboard.find_by_qtype(accomp).name,
                                        :score => score,
                                        :rankStr => "#{rank} of #{total}"}
            }
           }
       
   
    course_accomp
  
  end

  # Currently no usage in the project
  # Returns string for Top N Leaderboard Heading or accomplishments entry
  def self.leaderboard_heading(qtypeid)
    lt_entry = Leaderboard.find_by_qtype(qtypeid)
    if lt_entry
      lt_entry.name
    else
      "No Entry"
    end
  end
  
end
