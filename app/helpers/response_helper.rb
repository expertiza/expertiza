module ResponseHelper

  # Compute the currently awarded scores for the reviewee
  # If the new teammate review's score is greater than or less than 
  # the existing scores by a given percentage (defined by
  # the instructor) then notify the instructor.
  # ajbudlon, nov 18, 2008
  def self.compare_scores(new_response, questionnaire) 
    map_class = new_response.map.class
    existing_responses = map_class.get_assessments_for(new_response.map.reviewee)
    total, count = get_total_scores(existing_responses,new_response)     
    if count > 0
      notify_instructor(new_response.map.assignment, new_response, questionnaire, total, count)
    end
  end   
  
  # Compute the scores previously awarded to the recipient
  # ajbudlon, nov 18, 2008
  def self.get_total_scores(item_list,curr_item)
    total = 0
    count = 0
    item_list.each {
      | item | 
      if item.id != curr_item.id
        count += 1        
        total += item.get_total_score                
      end
    } 
    return total,count
  end
  
  # determine if the instructor should be notified
  # ajbudlon, nov 18, 2008
  def self.notify_instructor(assignment,curr_item,questionnaire,total,count)
     max_possible_score, weights = assignment.get_max_score_possible(questionnaire)
     new_score = curr_item.get_total_score.to_f*weights            
     existing_score = (total.to_f/count).to_f*weights 
     aq = AssignmentQuestionnaires.find_by_user_id_and_assignment_id_and_questionnaire_id(assignment.instructor_id, assignment.id, questionnaire.id)
    
     if aq == nil
       aq = AssignmentQuestionnaires.find_by_user_id_and_assignment_id_and_questionnaire_id(assignment.instructor_id, nil, nil)
     end
     allowed_difference = max_possible_score.to_f * aq.notification_limit / 100      
     if new_score < (existing_score - allowed_difference) or new_score > (existing_score + allowed_difference)
       new_pct = new_score.to_f/max_possible_score
       avg_pct = existing_score.to_f/max_possible_score
       curr_item.notify_on_difference(new_pct,avg_pct,aq.notification_limit)
     end    
  end  
  
  
      def load_questions (ques_num)
      @custom_questions = [
      "They state what the reader should know or be able to do after reading the article.",   #0
      "They are specific. ",  #1
      "They are appropriate and reasonable i.e. not too easy or too difficult for ECI 301 students.",       #2
      "They are observable, i.e. you wouldn't have to look inside the readers' head to know if they met this target.",  #3
      "Number of learning targets:",          #4
      "Assign a grade for the learning targets: ",      #5
      "Please make a comment about your rating. Provide suggestions for how the author can improve their learning targets:",    #6
      "File:"  ,                    #7
      "Write one compliment for the article:"     ,    #8
      "Write another compliment for the article:",   #9
      "Write one suggestion for the article:",             #10
      "Write another suggestion for the article:",     #11
      "How many sources are in the references list?",         #12
      "List the range of publication years for all sources, e.g. 1998-2006:",   #13
      "List the range of publication years for all sources, e.g. 1998-2006:",   #14
      "It lists all the sources in a section labeled \"References\".", #15
      "The author cites each of these sources in the article.",      #16
      "The citations are in APA format.",                  #17
      "The author cites at least 2 scholarly sources.",      #18
      "Most of the sources are current (less than 5 years old).",         #19
      "Taken together the sources represent a good balance of potential references for this topic.",      #20
      "The sources represent different viewpoints.",    #21
      "What other sources or perspectives might the author want to consider?",   #22
      "All materials (such as tables, graphs, images or videos created by other people or organizations) posted in the article are in accordance with the Attribution-Noncommercial-Share Alike 3.0 Unported license, or compatible.", #23
      "If not, which one(s) may infringe copyrights?", #24
      "Please make a comment about the sources. Explain how the author can improve the use of sources in the article:",#25
      "There are 4 multiple-choice questions.",#26
      "They each have four answer choices (A-D).",#27
      "There is a single correct (aka: not opinion-based) answer for each question.",#28
      "The questions assess the learning target(s)."   ,#29
      "The questions are appropriate and reasonable (not too easy and not too difficult)."    ,#30
      "The foils (the response options that are NOT the answer) are reasonable i.e. they are not very obviously incorrect answers."    ,#31
      "The response options are listed in alphabetical order."    ,#32
      "The correct answers are provided and listed BELOW all the questions."    ,#33
      "Type"   ,#34
      "Grades"    ,#35
      "Comments"    ,#36
      "Type"   ,#37
      "Grades"    ,#38
      "Comments"    ,#39
      "Type"   ,#40
      "Grades"    ,#41
      "Comments"    ,#42
      "Type"   ,#43
      "Grades"    ,#44
      "Comments"    ,#45
      "Is very important for future teachers to know",#46
      "Is based on researched information"    ,#47
      "Is highly relevant to current educational practice"    ,#48
      "Provides an excellent overview and in-depth discussion of key issues"    ,#49
      "Is relevant to future teachers"    ,#50
      "Is mostly based on researched information"   ,#51
      "Is applicable to today's schools"    ,#52
      "Provides a good overview and explores a few key ideas"   ,#53
      "Has useful points but some irrelevant information"   ,#54
      "Is half research; half the author's opinion"    ,#55
      "Is partially out-dated or may not reflect current practice"   ,#56
      "Contains good information but yields an incomplete understanding"   ,#57
      "Has one useful point"   ,#58
      "Is mostly the author's opinion."   ,#59
      "Is mostly irrelevant in today's schools"   ,#60
      "Focused on unimportant subtopics OR is overly general"   ,#61
      "Is not relevant to future teachers"   ,#62
      "Is entirely the author's opinion"   ,#63
      "Is obsolete"   ,#64
      "Lacks any substantive information"   ,#65
      "A sidebar with new information that was motivating to read/view"    ,#66
      "Many creative, attractive visuals and engaging, interactive elements"    ,#67
      "Multiple perspectives"    ,#68
      "Insightful interpretation & analysis throughout"    ,#69
      "Many compelling examples that support the main points (it \"shows\" not just \"tells\")"    ,#70
      "A sidebar that adds something new to the article"    ,#71
      "A few effective visuals or interactive elements"    ,#72
      "At least one interesting, fresh perspective"    ,#73
      "Frequent interpretation and analysis"    ,#74
      "Clearly explained and well supported points"    ,#75
      "A sidebar that repeats what is in the article"    ,#76
      "An effective visual or interactive element"    ,#77
      "One reasonable (possibly typical) perspective"    ,#78
      "Some interpretation and analysis"    ,#79
      "Supported points"    ,#80
      "A quote, link, etc. included as a sidebar, but that is not in a textbox"    ,#81
      "Visuals or interactive elements that are distracting"    ,#82
      "Only a biased perspective"    ,#83
      "Minimal analysis or interpretation"    ,#84
      "At least one clear and supported point"    ,#85
      "No sidebar included"    ,#86
      "No visuals or interactive elements"    ,#87
      "No perspective is acknowledged"    ,#88
      "No analysis or interpretation"    ,#89
      "No well-supported points"    ,#90
      "Cites 5 or more diverse, reputable sources in proper APA format"    ,#91
      "Provides citations for all presented information"    ,#92
      "Readily identifies bias: both the author's own and others"    ,#93
      "Cites 5 or more diverse, reputable sources with few APA errors"    ,#94
      "Provides citations for most information"    ,#95
      "Clearly differentiates between opinion and fact"    ,#96
      "Cites 5 or more reputable sources"    ,#97
      "Supports some claims with citation"    ,#98
      "Occasionally states opinion as fact"    ,#99
      "Cites 4 or more reputable sources"    ,#100
      "Has several unsupported claims"    ,#101
      "Routinely states opinion as fact and fails to acknowledge bias"  , #102
      "Cites 3 or fewer reputable sources"    ,#103
      "Has mostly unsupported claims"    ,#104
      "Is very biased and contains almost entirely opinions"    ,#105
      "Specific, appropriate, observable learning targets establish the purpose of the article"    ,#106
      "The article accomplishes its established goals"    ,#107
      "Excellent knowledge and application MC questions align with learning targets and assess important content"    ,#108
      "Specific and reasonable learning targets are stated"    ,#109
      "The article partially meets its established goals"    ,#110
      "Well constructed MC questions assess important content"    ,#111
      "Reasonable learning targets are stated"    ,#112
      "The content relates to its goals"    ,#113
      "MC questions assess important content"    ,#114
      "A learning target is included"    ,#115
      "Content does not achieve its goal, or goal is unclear"    ,#116
      "4 questions are included"    ,#117
      "Learning target is missing/ not actually a learning target"    ,#118
      "Article has no goal/ content is unfocused"    ,#119
      "Questions are missing"    ,#120
      "Is focused, organized, and easy to read throughout"    ,#121
      "Uses rich, descriptive vocabulary and a variety of effective sentence structures"    ,#122
      "Contains few to no mechanical errors"    ,#123
      "Has an effective introduction and a conclusion that synthesizes all of the material presented"    ,#124
      "Is organized and flows well"    ,#125
      "Uses effective vocabulary and sentence structures"    ,#126
      "Contains a few minor mechanical errors"    ,#127
      "Has an effective introduction and conclusion based on included information"    ,#128
      "Is mostly organized"    ,#129
      "Uses properly constructed sentences"    ,#130
      "Has a few distracting errors"    ,#131
      "Includes an introduction and a conclusion"    ,#132
      "Can be difficult to follow"    ,#133
      "Contains several awkward sentences"    ,#134
      "Has several distracting errors"    ,#135
      "Lacks either an introduction or a conclusion"    ,#136
      "Has minimal organization"    ,#137
      "Has many poorly constructed sentences"    ,#138
      "Has many mechanical errors that inhibit comprehension"    ,#139
      "Has neither a clear introduction nor a conclusion"    #140
      ]
      @custom_questions[ques_num]
    end
  
end
