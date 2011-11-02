class Response < ActiveRecord::Base
  belongs_to :map, :class_name => 'ResponseMap', :foreign_key => 'map_id'
  has_many :scores, :class_name => 'Score', :foreign_key => 'response_id', :dependent => :destroy
   def display_as_html(prefix = nil, count = nil, file_url = nil)
    identifier = ""
    # The following three lines print out the type of rubric before displaying
    # feedback.  Currently this is only done if the rubric is Author Feedback.
    # It doesn't seem necessary to print out the rubric type in the case of
    # a ReviewResponseMap.  Also, I'm not sure if that would have to be
    # TeamResponseMap for a team assignment.  Someone who understands the
    # situation better could add to the code later.
    if self.map.type.to_s == 'FeedbackResponseMap'
      identifier += "<H2>Feedback from author</H2>"
    end
    if prefix
      identifier += "<B>Reviewer:</B> "+self.map.reviewer.fullname
      str = prefix+"_"+self.id.to_s
    else
      identifier += '<B>'+self.map.get_title+'</B> '+count.to_s+'</B>'
      str = self.id.to_s
    end    
    code = identifier+'&nbsp;&nbsp;&nbsp;<a href="#" name= "review_'+str+'Link" onClick="toggleElement('+"'review_"+str+"','review'"+');return false;">hide review</a><BR/>'                
    code += "<B>Last reviewed:</B> "
    if self.updated_at.nil?
      code += "Not available"
    else
      code += self.updated_at.strftime('%A %B %d %Y, %I:%M%p')
    end
    code += '<div id="review_'+str+'" style=""><BR/><BR/>'
    
    # Test for whether Jen's custom rubric needs to be used
    if ((self.map.assignment.instructor_id == User.find_by_name("jkidd").id) && (self.map.type.to_s != 'FeedbackResponseMap'))
      if self.map.assignment.id < 469
        return custom_response_code(code, file_url) + "</div>"
      else
        return custom_response_code_2011(code, file_url) + "</div>"
      end
    end
  
    # End of custom code
    count = 0
    self.scores.each{
      | reviewScore |
      count += 1
      code += '<big><b>Question '+count.to_s+":</b> <I>"+Question.find_by_id(reviewScore.question_id).txt+"</I></big><BR/><BR/>"
      code += '<TABLE CELLPADDING="5"><TR><TD valign="top"><B>Score:</B></TD><TD><FONT style="BACKGROUND-COLOR:gold">'+reviewScore.score.to_s+"</FONT> out of <B>"+Question.find_by_id(reviewScore.question_id).questionnaire.max_question_score.to_s+"</B></TD></TR>"
      if reviewScore.comments != nil
        code += '<TR><TD valign="top"><B>Response:</B></TD><TD>' + reviewScore.comments.gsub("<","&lt;").gsub(">","&gt;").gsub(/\n/,'<BR/>')
      end
      code += '</TD></TR></TABLE><BR/>'
    }           
    
    if self.additional_comment != nil
      comment = self.additional_comment.gsub('^p','').gsub(/\n/,'<BR/>&nbsp;&nbsp;&nbsp;')
    else
      comment = ''
    end
    code += "<B>Additional Comment:</B><BR/>"+comment+"</div>"
    return code
  end  
  
 # Computes the total score awarded for a review
  def get_total_score
    total_score = 0
    
    self.map.questionnaire.questions.each{
      | question |
      item = Score.find_by_response_id_and_question_id(self.id, question.id)
      if(item != nil)
        total_score += item.score
      end
    }    
    return total_score        
  end  
  
 #Generate an email to the instructor when a new review exceeds the allowed difference
 #ajbudlon, nov 18, 2008
 def notify_on_difference(new_pct,avg_pct,limit)
   mapping = self.map
   instructor = mapping.assignment.instructor 
   Mailer.deliver_message(
     {:recipients => instructor.email,
      :subject => "Expertiza Notification: A review score is outside the acceptable range",
      :body => {        
        :first_name => ApplicationHelper::get_user_first_name(instructor),
        :reviewer_name => mapping.reviewer.fullname,
        :type => "review",
        :reviewee_name => mapping.reviewee.fullname,
        :limit => limit,
        :new_pct => new_pct,
        :avg_pct => avg_pct,
        :types => "reviews",
        :performer => "reviewer",
        :assignment => mapping.assignment,    
        :partial_name => 'limit_notify'
      }
     }
   )         
  end
 
  def delete
    self.scores.each {|score| score.destroy}
    self.destroy
  end  
end

def custom_response_code(code, file_url)
  begin
  review_scores = self.scores

  #********************Learning Targets******************
code = code + "<h2>Learning Targets</h2><hr>"
for i in 0..3
if review_scores[i].comments == "1"
case i
when 0 :code = code + "<img src=\"/images/Check-icon.png\"> They state what the reader should know or be able to do after reading the lesson<br/>"
when 1 :code = code + "<img src=\"/images/Check-icon.png\"> They are specific<br/>"
when 2 :code = code + "<img src=\"/images/Check-icon.png\"> They are appropriate and reasonable i.e. not too easy or too difficult for TLED 301 students<br/>"
when 3 :code = code + "<img src=\"/images/Check-icon.png\"> They are observable i.e. you wouldn't have to look inside the readers' head to know if they met this target<br/>"
end end end 
for i in 0..3
if review_scores[i].comments != "1"
case i
when 0 :code = code + "<img src=\"/images/delete_icon.png\"> They state what the reader should know or be able to do after reading the lesson<br/>" 
when 1 :code = code + "<img src=\"/images/delete_icon.png\"> They are specific<br/>"
when 2 :code = code + "<img src=\"/images/delete_icon.png\"> They are appropriate and reasonable i.e. not too easy or too difficult for TLED 301 students<br/>"
when 3 :code = code + "<img src=\"/images/delete_icon.png\"> They are observable i.e. you wouldn't have to look inside the readers' head to know if they met this target<br/>"
end end end
    code = code + "<br/><i>Number of Learning Targets: </i>#{review_scores[4].comments.gsub(/\"/,'&quot;').to_s}<br/>"
    code = code + "<br/><i>Grade: </i>#{review_scores[5].comments.gsub(/\"/,'&quot;').to_s}<br/>"
    code = code + "<br/><i>Comment: </i> <dl><dd>#{review_scores[6].comments.gsub(/\"/,'&quot;').to_s}</dl></dd>"

  #*******************Content************************
  code = code + "<h2>Content</h2><hr>"
  code = code + "<i>File:</i>"
  if file_url.nil?
    code = code + "File has not been uploaded<br/>"
  else
    code = code + file_url.to_s + "<br/>"
  end
   code = code + "<i>Compliment:</i>"
    code = code + "<ul><li>#{review_scores[8].comments.gsub(/\"/,'&quot;').to_s}</li><li>#{review_scores[9].comments.gsub(/\"/,'&quot;').to_s}</li></ul>"
  code = code + "<i>Suggestion:</i>"
    code = code + "<ul><li>#{review_scores[10].comments.gsub(/\"/,'&quot;').to_s}</li><li>#{review_scores[11].comments.gsub(/\"/,'&quot;').to_s}</li></ul>"

  #*******************Sources and Use of Source Material************************
  code = code + "<h2>Sources and Use of Source Material</h2><hr>"
    code = code + "<br/>How many sources are in the references list?: #{review_scores[12].comments.gsub(/\"/,'&quot;').to_s}<br/>"
    code = code + "<br/>List the range of publication years for all sources, e.g. 1998-2006: <b>#{review_scores[13].comments.gsub(/\"/,'&quot;').to_s} - #{review_scores[14].comments.gsub(/\"/,'&quot;').to_s}</b><br/><br/>"

 for i in 15..21
if review_scores[i].comments == "1"
case i
when 15 :code = code + "<img src=\"/images/Check-icon.png\"> It lists all the sources in a section labeled \"References\"<br/>"
when 16 :code = code + "<img src=\"/images/Check-icon.png\"> The author cites each of these sources in the lesson<br/>"  
when 17 :code = code + "<img src=\"/images/Check-icon.png\"> The citations are in APA format<br/>"
when 18 :code = code + "<img src=\"/images/Check-icon.png\"> The author cites at least 2 scholarly sources<br/>"
when 19 :code = code + "<img src=\"/images/Check-icon.png\"> Most of the sources are current (less than 5 years old)<br/>"
when 20 :code = code + "<img src=\"/images/Check-icon.png\"> Taken together the sources represent a good balance of potential references for this topic<br/>"
when 21 :code = code + "<img src=\"/images/Check-icon.png\"> The sources represent different viewpoints<br/>"
end end end
for i in 15..21
if review_scores[i].comments != "1"
case i
when 15 :code = code + "<img src=\"/images/delete_icon.png\"> It lists all the sources in a section labeled \"References\"<br/>"
when 16 :code = code + "<img src=\"/images/delete_icon.png\"> The author cites each of these sources in the lesson<br/>"
when 17 :code = code + "<img src=\"/images/delete_icon.png\"> The citations are in APA format<br/>"
when 18 :code = code + "<img src=\"/images/delete_icon.png\"> The author cites at least 2 scholarly sources<br/>"
when 19 :code = code + "<img src=\"/images/delete_icon.png\"> Most of the sources are current (less than 5 years old)<br/>"
when 20 :code = code + "<img src=\"/images/delete_icon.png\"> Taken together the sources represent a good balance of potential references for this topic<br/>"
when 21 :code = code + "<img src=\"/images/delete_icon.png\"> The sources represent different viewpoints<br/>"
end end end
code = code + "<br/><b>What other sources or perspectives might the author want to consider?</b><br/>"
code = code + "<dl><dd>#{review_scores[22].comments.gsub(/\"/,'&quot;').to_s}</dl></dd>"
if review_scores[23].comments == "1"
    code = code + "<img src=\"/images/Check-icon.png\"> All materials (such as tables, graphs, images or videos created by other people or organizations) posted are in the lesson in accordance with the Attribution-Noncommercial-Share Alike 3.0 Unported license, or compatible. <br/>"
  else
    code = code + "<img src=\"/images/delete_icon.png\"> All materials (such as tables, graphs, images or videos created by other people or organizations) posted are in the lesson in accordance with the Attribution-Noncommercial-Share Alike 3.0 Unported license, or compatible<br/>"
  end
  code = code + "<br/><b>If not, which one(s) may infringe copyrights, or what areas of text may need citations, revisions or elaboration?</b><br/>"
    code = code + "<dl><dd>#{review_scores[24].comments.gsub(/\"/,'&quot;').to_s}</dl></dd>"

  code = code + "<br/>Please make a comment about the sources. Explain how the author can improve the use of sources in the lesson.<br/>"
    code = code + "<dl><dd>#{review_scores[25].comments.gsub(/\"/,'&quot;').to_s}</dl></dd>"

  #*******************Multiple Choice Questions************************
  code = code + "<h2>Multiple Choice Questions</h2><hr>"
for i in 26..33
if review_scores[i].comments == "1"
case i
when 26 :code = code + "<img src=\"/images/Check-icon.png\"> There are 4 multiple-choice questions<br/>"
when 27 :code = code + "<img src=\"/images/Check-icon.png\"> They each have four answer choices (A-D)<br/>"
when 28 :code = code + "<img src=\"/images/Check-icon.png\"> There is a single correct (aka: not opinion-based) answer for each question<br/>"
when 29 :code = code + "<img src=\"/images/Check-icon.png\"> The questions assess the learning target(s)<br/>"
when 30 :code = code + "<img src=\"/images/Check-icon.png\"> The questions are appropriate and reasonable (not too easy and not too difficult)<br/>"
when 31 :code = code + "<img src=\"/images/Check-icon.png\"> The foils (the response options that are NOT the answer) are reasonable i.e. they are not very obviously incorrect answers<br/>"
when 32 :code = code + "<img src=\"/images/Check-icon.png\"> The response options are listed in alphabetical order<br/>"
when 33 :code = code + "<img src=\"/images/Check-icon.png\"> The correct answers are provided and listed BELOW all the questions<br/>"
end end end 
for i in 26..33
if review_scores[i].comments != "1"
case i
when 26 :code = code + "<img src=\"/images/delete_icon.png\"> There are 4 multiple-choice questions<br/>"
when 27 :code = code + "<img src=\"/images/delete_icon.png\"> They each have four answer choices (A-D)<br/>"
when 28 :code = code + "<img src=\"/images/delete_icon.png\"> There is a single correct (aka: not opinion-based) answer for each question<br/>"
when 29 :code = code + "<img src=\"/images/delete_icon.png\"> The questions assess the learning target(s)<br/>"
when 30 :code = code + "<img src=\"/images/delete_icon.png\"> The questions are appropriate and reasonable (not too easy and not too difficult)<br/>"
when 31 :code = code + "<img src=\"/images/delete_icon.png\"> The foils (the response options that are NOT the answer) are reasonable i.e. they are not very obviously incorrect answers<br/>"
when 32 :code = code + "<img src=\"/images/delete_icon.png\"> The response options are listed in alphabetical order<br/>"  
when 33 :code = code + "<img src=\"/images/delete_icon.png\"> The correct answers are provided and listed BELOW all the questions<br/>"
end end end 
code = code + "<br/><h3>Questions</h3>"
    code = code + "<i>Type: </i><b>#{review_scores[34].comments.gsub(/\"/,'&quot;').to_s}</b><br/>"
    code = code + "<i>Grade: </i><b>#{review_scores[35].comments.gsub(/\"/,'&quot;').to_s}</b><br/>"
    code = code + "<i>Comment: </i><dl><dd>#{review_scores[36].comments.gsub(/\"/,'&quot;').to_s}</dl></dd><br/>"

    code = code + "<i>Type: </i><b>#{review_scores[37].comments.gsub(/\"/,'&quot;').to_s}</b><br/>"
    code = code + "<i>Grade: </i><b>#{review_scores[38].comments.gsub(/\"/,'&quot;').to_s}</b><br/>"
    code = code + "<i>Comment: </i><dl><dd>#{review_scores[39].comments.gsub(/\"/,'&quot;').to_s}</dl></dd><br/>"

    code = code + "<i>Type: </i><b>#{review_scores[40].comments.gsub(/\"/,'&quot;').to_s}</b><br/>"
    code = code + "<i>Grade: </i><b>#{review_scores[41].comments.gsub(/\"/,'&quot;').to_s}</b><br/>"
    code = code + "<i>Comment: </i><dl><dd>#{review_scores[42].comments.gsub(/\"/,'&quot;').to_s}</dl></dd><br/>"

    code = code + "<i>Type: </i><b>#{review_scores[43].comments.gsub(/\"/,'&quot;').to_s}</b><br/>"
    code = code + "<i>Grade: </i><b>#{review_scores[44].comments.gsub(/\"/,'&quot;').to_s}</b><br/>"
    code = code + "<i>Comment: </i><dl><dd>#{review_scores[45].comments.gsub(/\"/,'&quot;').to_s}</dl></dd><br/>"

  #*******************Rubric************************
  code = code + "<h2>Rubric</h2><hr>"

  code = code + "<h3>Importance</h3>"
  code = code +
           "<div align=\"center\">The information selected by the author:</div><table class='general'>
            <tr>
              <th>5 - Very Important   </th>
              <th>4 - Quite Important  </th>
              <th>3 - Some Importance  </th>
              <th>2 - Little Importance</th>
              <th>1 - No Importance    </th>
            </tr>
            <tr>"

  code = code + "<td><ul>"
for i in 46..49
if review_scores[i].comments == "1"
case i
when 46 :code = code + "<li>Is very important for future teachers to know</li>"
when 47 :code = code + "<li>Is based on researched information</li>" 
when 48 :code = code + "<li>Is highly relevant to current educational practice</li>"
when 49 :code = code + "<li>Provides an excellent overview and in-depth discussion of key issues</li>"
end end end
code = code + "</ul></td>" 
code = code + "<td><ul>"  
for i in 50..53
if review_scores[i].comments == "1"
case i
when 50 :code = code + "<li>Is relevant to future teachers</li>" 
when 51 :code = code + "<li>Is mostly based on researched information</li>"
when 52 :code = code + "<li>Is applicable to today's schools</li>" 
when 53 :code = code + "<li>Provides a good overview and explores a few key ideas</li>" 
end end end
code = code + "</ul></td>" 
code = code + "<td><ul>" 
for i in 54..57
if review_scores[i].comments == "1"
case i
when 54 :code = code + "<li>Has useful points but some irrelevant information</li>" 
when 55 :code = code + "<li>Is half research; half the author's opinion</li>" 
when 56 :code = code + "<li>Is partially out-dated or may not reflect current practice</li>"  
when 57 :code = code + "<li>Contains good information but yields an incomplete understanding</li>"
end end end
code = code + "</ul></td>" 
code = code + "<td><ul>"
for i in 58..61
if review_scores[i].comments == "1"
case i  
when 58 :code = code + "<li>Has one useful point</li>" 
when 59 :code = code + "<li>Is mostly the author's opinion.</li>"
when 60 :code = code + "<li>Is mostly irrelevant in today's schools</li>" 
when 61 :code = code + "<li>Focused on unimportant subtopics OR is overly general</li>"  
end end end
code = code + "</ul></td>"  code = code + "<td><ul>"  
for i in 62..65
if review_scores[i].comments == "1"
case i
when 62 :code = code + "<li>Is not relevant to future teachers</li>" 
when 63 :code = code + "<li>Is entirely the author's opinion</li>" 
when 64 :code = code + "<li>Is obsolete</li>" 
when 65 :code = code + "<li>Lacks any substantive information</li>"
end end end
code = code + "</ul></td></tr>"
code = code + "</table>"
code = code + "<h3>Interest</h3>"
code = code +
           "<div align=\"center\">To attract and maintain attention, the lesson has:</div><table class='general'>
            <tr>
              <th>5 - Extremely Interesting   </th>
              <th>4 - Quite Interesting  </th>
              <th>3 - Reasonably Interesting  </th>
              <th>2 - Little Interest</th>
              <th>1 - No Interest    </th>
            </tr>
            <tr>"

code = code + "<td><ul>"
for i in 66..70
if review_scores[i].comments == "1"
case i
when 66 :code = code + "<li>A sidebar with new information that was motivating to read/view</li>"
when 67 :code = code + "<li>Many creative, attractive visuals and engaging, interactive elements</li>"
when 68 :code = code + "<li>Multiple perspectives</li>"
when 69 :code = code + "<li>Insightful interpretation & analysis throughout</li>"
when 70 :code = code + "<li>Many compelling examples that support the main points (it \"shows\" not just \"tells\")</li>"
end end end
code = code + "</ul></td>"
code = code + "<td><ul>"
for i in 71..75
if review_scores[i].comments == "1"
case i
when 71 :code = code + "<li>A sidebar that adds something new to the lesson</li>"
when 72 :code = code + "<li>A few effective visuals or interactive elements</li>"
when 73 :code = code + "<li>At least one interesting, fresh perspective</li>"
when 74 :code = code + "<li>Frequent interpretation and analysis</li>"
when 75 :code = code + "<li>Clearly explained and well supported points</li>"
end end end
code = code + "</ul></td>"
code = code + "<td><ul>"
for i in 76..80
if review_scores[i].comments == "1"
case i
when 76 :code = code + "<li>A sidebar that repeats what is in the lesson</li>"
when 77 :code = code + "<li>An effective visual or interactive element</li>"
when 78 :code = code + "<li>One reasonable (possibly typical) perspective</li>"
when 79 :code = code + "<li>Some interpretation and analysis</li>"
when 80 :code = code + "<li>Supported points</li>"
end end end
code = code + "</ul></td>"
code = code + "<td><ul>"
for i in 81..85
if review_scores[i].comments == "1"
case i
when 81 :code = code + "<li>A quote, link, etc. included as a sidebar, but that is not in a textbox</li>"
when 82 :code = code + "<li>Visuals or interactive elements that are distracting</li>"
when 83 :code = code + "<li>Only a biased perspective</li>"
when 84 :code = code + "<li>Minimal analysis or interpretation</li>"
when 85 :code = code + "<li>At least one clear and supported point</li>"
end end end
code = code + "</ul></td>"
code = code + "<td><ul>"
for i in 86..90
if review_scores[i].comments == "1"
case i
when 86 :code = code + "<li>No side bar included</li>"
when 87 :code = code + "<li>No visuals or interactive elements</li>"
when 88 :code = code + "<li>No perspective is acknowledged</li>"
when 89 :code = code + "<li>No analysis or interpretation</li>"
when 90 :code = code + "<li>No well-supported points</li>"
end end end 
code = code + "</ul></td></tr>"
code = code + "</table>"
code = code + "<h3>Credibility</h3>"
code = code +
           "<div align=\"center\">To demonstrate its credibility the lesson:</div><table class='general'>
            <tr>
              <th>5 - Completely Credible   </th>
              <th>4 - Substantial Credibility  </th>
              <th>3 - Reasonable Credibility </th>
              <th>2 - Limited Credibility</th>
              <th>1 - Not Credible   </th>
            </tr>
            <tr>"
code = code + "<td><ul>"
for i in 91..93
if review_scores[i].comments == "1"
case i
when 91 :code = code + "<li>Cites 5 or more diverse, reputable sources in proper APA format</li>"
when 92 :code = code + "<li>Provides citations for all presented information</li>"
when 93 :code = code + "<li>Readily identifies bias: both the author's own and others</li>"
end end end
code = code + "</ul></td>"
code = code + "<td><ul>"
for i in 94..96
if review_scores[i].comments == "1"
case i
when 94 :code = code + "<li>Cites 5 or more diverse, reputable sources with few APA errors</li>"
when 95 :code = code + "<li>Provides citations for most information</li>"
when 96 :code = code + "<li>Clearly differentiates between opinion and fact</li>"
end end end
code = code + "</ul></td>"
code = code + "<td><ul>"
for i in 97..99
if review_scores[i].comments == "1"
case i
when 97 :code = code + "<li>Cites 5 or more reputable sources</li>"
when 98 :code = code + "<li>Supports some claims with citation</li>"
when 99 :code = code + "<li>Occasionally states opinion as fact</li>"
end end end
code = code + "</ul></td>"
code = code + "<td><ul>"
for i in 100..102
if review_scores[i].comments == "1"
case i
when 100 :code = code + "<li>Cites 4 or more reputable sources</li>"
when 101 :code = code + "<li>Has several unsupported claims</li>"
when 102 :code = code + "<li>Routinely states opinion as fact and fails to acknowledge bias</li>"
end end end
code = code + "</ul></td>"
code = code + "<td><ul>"
for i in 103..105
if review_scores[i].comments == "1"
case i
when 103 :code = code + "<li>Cites 3 or fewer reputable sources</li>"
when 104 :code = code + "<li>Has mostly unsupported claims</li>"
when 105 :code = code + "<li>Is very biased and contains almost entirely opinions</li>"
end end end
code = code + "</ul></td></tr>"
code = code + "</table>"
code = code + "<h3>Pedagogy</h3>"
code = code +
           "<div align=\"center\">To help guide the reader:</div><table class='general'>
            <tr>
              <th>5 - Superior   </th>
              <th>4 - Effective  </th>
              <th>3 - Acceptable </th>
              <th>2 - Deficient</th>
              <th>1 - Absent   </th>
            </tr>
            <tr>"

  code = code + "<td><ul>"
for i in 106..108
if review_scores[i].comments == "1"
case i
when 106 :code = code + "<li>Specific, appropriate, observable learning targets establish the purpose of the lesson</li>"
when 107 :code = code + "<li>The lesson accomplishes its established goals</li>"
when 108 :code = code + "<li>Excellent knowledge and application MC questions align with learning targets and assess important content</li>"
end end end
code = code + "</ul></td>"
code = code + "<td><ul>"
for i in 109..111
if review_scores[i].comments == "1"
case i
when 109 :code = code + "<li>Specific and reasonable learning targets are stated</li>"
when 110 :code = code + "<li>The lesson partially meets its established goals</li>"
when 111 :code = code + "<li>Well constructed MC questions assess important content</li>"
end end end
code = code + "</ul></td>"
code = code + "<td><ul>"
for i in 112..114
if review_scores[i].comments == "1"
case i
when 112 :code = code + "<li>Reasonable learning targets are stated</li>"
when 113 :code = code + "<li>The content relates to its goals</li>"
when 114 :code = code + "<li>MC questions assess important content</li>"
end end end
code = code + "</ul></td>"
code = code + "<td><ul>"
for i in 115..117
if review_scores[i].comments == "1"
case i
when 115 :code = code + "<li>A learning target is included</li>"
when 116 :code = code + "<li>Content does not achieve its goal, or goal is unclear</li>"
when 117 :code = code + "<li>4 questions are included</li>"
end end end
code = code + "</ul></td>"
code = code + "<td><ul>"
for i in 118..120
if review_scores[i].comments == "1"
case i
when 118 :code = code + "<li>Learning target is missing/ not actually a learning target</li>"
when 119 :code = code + "<li>Lesson has no goal/ content is unfocused</li>"
when 120 :code = code + "<li>Questions are missing</li>"
end end end
code = code + "</ul></td></tr>"
code = code + "</table>"
code = code + "<h3>Writing Quality</h3>"
code = code +
           "<div align=\"center\">The writing:</div><table class='general'>
            <tr>
              <th>5 - Excellently Written   </th>
              <th>4 - Well Written  </th>
              <th>3 - Reasonably Written  </th>
              <th>2 - Fairly Written</th>
              <th>1 - Poorly Written    </th>
            </tr>
            <tr>"
code = code + "<td><ul>"
for i in 121..124
if review_scores[i].comments == "1"
case i
when 121 :code = code + "<li>Is focused, organized, and easy to read throughout</li>"
when 122 :code = code + "<li>Uses rich, descriptive vocabulary and a variety of effective sentence structures</li>"
when 123 :code = code + "<li>Contains few to no mechanical errors</li>"
when 124 :code = code + "<li>Has an effective introduction and a conclusion that synthesizes all of the material presented</li>"
end end end
code = code + "</ul></td>"
code = code + "<td><ul>"
for i in 125..128
if review_scores[i].comments == "1"
case i
when 125 :code = code + "<li>Is organized and flows well</li>"
when 126 :code = code + "<li>Uses effective vocabulary and sentence structures</li>"
when 127 :code = code + "<li>Contains a few minor mechanical errors</li>"
when 128 :code = code + "<li>Has an effective introduction and conclusion based on included information</li>"
end end end
code = code + "</ul></td>"
code = code + "<td><ul>"
for i in 129..132
if review_scores[i].comments == "1"
case i
when 129 :code = code + "<li>Is mostly organized</li>"
when 130 :code = code + "<li>Uses properly constructed sentences</li>"
when 131 :code = code + "<li>Has a few distracting errors</li>"
when 132 :code = code + "<li>Includes an introduction and a conclusion</li>"
end end end
code = code + "</ul></td>"
code = code + "<td><ul>"
for i in 133..136
if review_scores[i].comments == "1"
case i
when 133 :code = code + "<li>Can be difficult to follow</li>"
when 134 :code = code + "<li>Contains several awkward sentences</li>"
when 135 :code = code + "<li>Has several distracting errors</li>"
when 136 :code = code + "<li>Lacks either an introduction or a conclusion</li>"
end end end
code = code + "</ul></td>"
code = code + "<td><ul>"
for i in 137..140
if review_scores[i].comments == "1"
case i
when 137 :code = code + "<li>Has minimal organization</li>"
when 138 :code = code + "<li>Has many poorly constructed sentences</li>"
when 139 :code = code + "<li>Has many mechanical errors that inhibit comprehension</li>"
when 140 :code = code + "<li>Has neither a clear introduction nor a conclusion</li>"
end end end
code = code + "</ul></td></tr>"
code = code + "</table>"

  #*******************Ratings************************
  code = code + "<h2>Ratings</h2><hr>"

  code = code + "<h3>Importance</h3>"
    code = code + "<i>Grade: </i><b>#{review_scores[141].comments.gsub(/\"/,'&quot;').to_s}</b><br/>"
    code = code + "<i>Comment: </i><dl><dd>#{review_scores[142].comments.gsub(/\"/,'&quot;').to_s}</dl></dd><br/>"

  code = code + "<h3>Interest</h3>"
    code = code + "<i>Grade: </i><b>#{review_scores[143].comments.gsub(/\"/,'&quot;').to_s}</b><br/>"
    code = code + "<i>Comment: </i><dl><dd>#{review_scores[144].comments.gsub(/\"/,'&quot;').to_s}</dl></dd><br/>"

  code = code + "<h3>Credibility</h3>"
    code = code + "<i>Grade: </i><b>#{review_scores[145].comments.gsub(/\"/,'&quot;').to_s}</b><br/>"
    code = code + "<i>Comment: </i><dl><dd>#{review_scores[146].comments.gsub(/\"/,'&quot;').to_s}</dl></dd><br/>"

  code = code + "<h3>Pedagogy</h3>"
    code = code + "<i>Grade: </i><b>#{review_scores[147].comments.gsub(/\"/,'&quot;').to_s}</b><br/>"
    code = code + "<i>Comment: </i><dl><dd>#{review_scores[148].comments.gsub(/\"/,'&quot;').to_s}</dl></dd><br/>"

  code = code + "<h3>Writing Quality</h3>"
    code = code + "<i>Grade: </i><b>#{review_scores[149].comments.gsub(/\"/,'&quot;').to_s}</b><br/>"
    code = code + "<i>Comment: </i><dl><dd>#{review_scores[150].comments.gsub(/\"/,'&quot;').to_s}</dl></dd><br/>"
  rescue
    code += "Error " + $! 
  end  
  code
end

def custom_response_code_2011(code, file_url)
  begin
  review_scores = self.scores
  #********************Learning Targets******************
  code = code + "<h2>Learning Targets</h2><hr>"

for i in 0..3
if review_scores[i].comments == "1"
case i
when 0 :code = code + "<img src=\"/images/Check-icon.png\"> They state what the reader should know or be able to do after reading the lesson<br/>"
when 1 :code = code + "<img src=\"/images/Check-icon.png\"> They are specific<br/>"
when 2 :code = code + "<img src=\"/images/Check-icon.png\"> They are appropriate and reasonable i.e. not too easy or too difficult for TLED 301 students<br/>"
when 3 :code = code + "<img src=\"/images/Check-icon.png\"> They are observable i.e. you wouldn't have to look inside the readers' head to know if they met this target<br/>"
end end end 
for i in 0..3
if review_scores[i].comments != "1"
case i
when 0 :code = code + "<img src=\"/images/delete_icon.png\"> They state what the reader should know or be able to do after reading the lesson<br/>" 
when 1 :code = code + "<img src=\"/images/delete_icon.png\"> They are specific<br/>"
when 2 :code = code + "<img src=\"/images/delete_icon.png\"> They are appropriate and reasonable i.e. not too easy or too difficult for TLED 301 students<br/>"
when 3 :code = code + "<img src=\"/images/delete_icon.png\"> They are observable i.e. you wouldn't have to look inside the readers' head to know if they met this target<br/>"
end end end

    code = code + "<br/><i>Number of Learning Targets: </i>#{review_scores[4].comments.gsub(/\"/,'&quot;').to_s}<br/>"
    code = code + "<br/><i>Grade: </i>#{review_scores[5].comments.gsub(/\"/,'&quot;').to_s}<br/>"
    code = code + "<br/><i>Comment: </i> <dl><dd>#{review_scores[6].comments.gsub(/\"/,'&quot;').to_s}</dl></dd>"

  #*******************Content************************
  code = code + "<h2>Content</h2><hr>"
  code = code + "<i>File:</i>"
  if file_url.nil?
    code = code + "File has not been uploaded<br/>"
  else
    code = code + file_url.to_s + "<br/>"
  end

  code = code + "<i>Compliment:</i>"
    code = code + "<ul><li>#{review_scores[8].comments.gsub(/\"/,'&quot;').to_s}</li><li>#{review_scores[9].comments.gsub(/\"/,'&quot;').to_s}</li></ul>"
  code = code + "<i>Suggestion:</i>"
    code = code + "<ul><li>#{review_scores[10].comments.gsub(/\"/,'&quot;').to_s}</li><li>#{review_scores[11].comments.gsub(/\"/,'&quot;').to_s}</li></ul>"

  #*******************Sources and Use of Source Material************************
  code = code + "<h2>Sources and Use of Source Material</h2><hr>"
    code = code + "<br/>How many sources are in the references list?: #{review_scores[12].comments.gsub(/\"/,'&quot;').to_s}<br/>"
    code = code + "<br/>List the range of publication years for all sources, e.g. 1998-2006: <b>#{review_scores[13].comments.gsub(/\"/,'&quot;').to_s} - #{review_scores[14].comments.gsub(/\"/,'&quot;').to_s}</b><br/><br/>"


for i in 15..21
if review_scores[i].comments == "1"
case i
when 15 :code = code + "<img src=\"/images/Check-icon.png\"> It lists all the sources in a section labeled \"References\"<br/>"
when 16 :code = code + "<img src=\"/images/Check-icon.png\"> The author cites each of these sources in the lesson<br/>"  
when 17 :code = code + "<img src=\"/images/Check-icon.png\"> The citations are in APA format<br/>"
when 18 :code = code + "<img src=\"/images/Check-icon.png\"> The author cites at least 2 scholarly sources<br/>"
when 19 :code = code + "<img src=\"/images/Check-icon.png\"> Most of the sources are current (less than 5 years old)<br/>"
when 20 :code = code + "<img src=\"/images/Check-icon.png\"> Taken together the sources represent a good balance of potential references for this topic<br/>"
when 21 :code = code + "<img src=\"/images/Check-icon.png\"> The sources represent different viewpoints<br/>"
end end end
for i in 15..21
if review_scores[i].comments != "1"
case i
when 15 :code = code + "<img src=\"/images/delete_icon.png\"> It lists all the sources in a section labeled \"References\"<br/>"
when 16 :code = code + "<img src=\"/images/delete_icon.png\"> The author cites each of these sources in the lesson<br/>"
when 17 :code = code + "<img src=\"/images/delete_icon.png\"> The citations are in APA format<br/>"
when 18 :code = code + "<img src=\"/images/delete_icon.png\"> The author cites at least 2 scholarly sources<br/>"
when 19 :code = code + "<img src=\"/images/delete_icon.png\"> Most of the sources are current (less than 5 years old)<br/>"
when 20 :code = code + "<img src=\"/images/delete_icon.png\"> Taken together the sources represent a good balance of potential references for this topic<br/>"
when 21 :code = code + "<img src=\"/images/delete_icon.png\"> The sources represent different viewpoints<br/>"
end end end

 code = code + "<br/><b>What other sources or perspectives might the author want to consider?</b><br/>"
 code = code + "<dl><dd>#{review_scores[22].comments.gsub(/\"/,'&quot;').to_s}</dl></dd>"

  if review_scores[23].comments == "1"
    code = code + "<img src=\"/images/Check-icon.png\"> All materials (such as tables, graphs, images or videos created by other people or organizations) posted are in the lesson in accordance with the Attribution-Noncommercial-Share Alike 3.0 Unported license, or compatible <b>and</b> all information quoted or paraphrased from other sources is properly cited and commented on so there is no evidence of plagiarism. There are no large sections of text copied from (or closely resembling) other sources.<br/>"
  else
    code = code + "<img src=\"/images/delete_icon.png\"> All materials (such as tables, graphs, images or videos created by other people or organizations) posted are in the lesson in accordance with the Attribution-Noncommercial-Share Alike 3.0 Unported license, or compatible<b>and</b> all information quoted or paraphrased from other sources is properly cited and commented on so there is no evidence of plagiarism. There are no large sections of text copied from (or closely resembling) other sources.<br/>"
  end

  code = code + "<br/><b>If not, which one(s) may infringe copyrights, or what areas of text may need citations, revisions or elaboration?</b><br/>"
    code = code + "<dl><dd>#{review_scores[24].comments.gsub(/\"/,'&quot;').to_s}</dl></dd>"

  code = code + "<br/>Please make a comment about the sources. Explain how the author can improve the use of sources in the lesson.<br/>"
    code = code + "<dl><dd>#{review_scores[25].comments.gsub(/\"/,'&quot;').to_s}</dl></dd>"

  #*******************Multiple Choice Questions************************
  code = code + "<h2>Multiple Choice Questions</h2><hr>"
for i in 26..33
if review_scores[i].comments == "1"
case i
when 26 :code = code + "<img src=\"/images/Check-icon.png\"> There are 4 multiple-choice questions<br/>"
when 27 :code = code + "<img src=\"/images/Check-icon.png\"> They each have four answer choices (A-D)<br/>"
when 28 :code = code + "<img src=\"/images/Check-icon.png\"> There is a single correct (aka: not opinion-based) answer for each question<br/>"
when 29 :code = code + "<img src=\"/images/Check-icon.png\"> The questions assess the learning target(s)<br/>"
when 30 :code = code + "<img src=\"/images/Check-icon.png\"> The questions are appropriate and reasonable (not too easy and not too difficult)<br/>"
when 31 :code = code + "<img src=\"/images/Check-icon.png\"> The foils (the response options that are NOT the answer) are reasonable i.e. they are not very obviously incorrect answers<br/>"
when 32 :code = code + "<img src=\"/images/Check-icon.png\"> The response options are listed in alphabetical order<br/>"
when 33 :code = code + "<img src=\"/images/Check-icon.png\"> The correct answers are provided and listed BELOW all the questions<br/>"
end end end 
for i in 26..33
if review_scores[i].comments != "1"
case i
when 26 :code = code + "<img src=\"/images/delete_icon.png\"> There are 4 multiple-choice questions<br/>"
when 27 :code = code + "<img src=\"/images/delete_icon.png\"> They each have four answer choices (A-D)<br/>"
when 28 :code = code + "<img src=\"/images/delete_icon.png\"> There is a single correct (aka: not opinion-based) answer for each question<br/>"
when 29 :code = code + "<img src=\"/images/delete_icon.png\"> The questions assess the learning target(s)<br/>"
when 30 :code = code + "<img src=\"/images/delete_icon.png\"> The questions are appropriate and reasonable (not too easy and not too difficult)<br/>"
when 31 :code = code + "<img src=\"/images/delete_icon.png\"> The foils (the response options that are NOT the answer) are reasonable i.e. they are not very obviously incorrect answers<br/>"
when 32 :code = code + "<img src=\"/images/delete_icon.png\"> The response options are listed in alphabetical order<br/>"  
when 33 :code = code + "<img src=\"/images/delete_icon.png\"> The correct answers are provided and listed BELOW all the questions<br/>"
end end end 
    code = code + "<br/><h3>Questions</h3>"
    code = code + "<i>Type: </i><b>#{review_scores[34].comments.gsub(/\"/,'&quot;').to_s}</b><br/>"
    code = code + "<i>Grade: </i><b>#{review_scores[35].comments.gsub(/\"/,'&quot;').to_s}</b><br/>"
    code = code + "<i>Comment: </i><dl><dd>#{review_scores[36].comments.gsub(/\"/,'&quot;').to_s}</dl></dd><br/>"

    code = code + "<i>Type: </i><b>#{review_scores[37].comments.gsub(/\"/,'&quot;').to_s}</b><br/>"
    code = code + "<i>Grade: </i><b>#{review_scores[38].comments.gsub(/\"/,'&quot;').to_s}</b><br/>"
    code = code + "<i>Comment: </i><dl><dd>#{review_scores[39].comments.gsub(/\"/,'&quot;').to_s}</dl></dd><br/>"

    code = code + "<i>Type: </i><b>#{review_scores[40].comments.gsub(/\"/,'&quot;').to_s}</b><br/>"
    code = code + "<i>Grade: </i><b>#{review_scores[41].comments.gsub(/\"/,'&quot;').to_s}</b><br/>"
    code = code + "<i>Comment: </i><dl><dd>#{review_scores[42].comments.gsub(/\"/,'&quot;').to_s}</dl></dd><br/>"

    code = code + "<i>Type: </i><b>#{review_scores[43].comments.gsub(/\"/,'&quot;').to_s}</b><br/>"
    code = code + "<i>Grade: </i><b>#{review_scores[44].comments.gsub(/\"/,'&quot;').to_s}</b><br/>"
    code = code + "<i>Comment: </i><dl><dd>#{review_scores[45].comments.gsub(/\"/,'&quot;').to_s}</dl></dd><br/>"


  #*******************Rubric************************
  code = code + "<h2>Rubric</h2><hr>"
  code = code + "<h3>Importance</h3>"
  code = code +
           "<div align=\"center\">The information selected by the author:</div><table class='general'>
            <tr>
              <th>5 - Very Important   </th>
              <th>4 - Quite Important  </th>
              <th>3 - Some Importance  </th>
              <th>2 - Little Importance</th>
              <th>1 - No Importance    </th>
            </tr>
            <tr>"

  code = code + "<td><ul>"
  if review_scores[46].comments == "1"
    code = code + "<li>Is important for future teachers to know.</li>"
  end
  if review_scores[47].comments == "1"
    code = code + "<li>Explains one or more key issues clearly and in some depth using researched information.</li>"
  end
  code = code + "</ul></td>"

  code = code + "<td><ul>"
  if review_scores[48].comments == "1"
    code = code + "<li>Is relevant to future teachers.</li>"
  end
  if review_scores[49].comments == "1"
    code = code + "<li>Provides a good overview of one or more key ideas using researched information.</li>"
  end
  code = code + "</ul></td>"

  code = code + "<td><ul>"
  if review_scores[50].comments == "1"
    code = code + "<li>Has some useful points but some irrelevant information.</li>"
  end
  if review_scores[51].comments == "1"
    code = code + "<li>Contains some good information but fails to focus or elaborate on key ideas.</li>"
  end
  code = code + "</ul></td>"

  code = code + "<td><ul>"
  if review_scores[52].comments == "1"
    code = code + "<li>Has one useful point.</li>"
  end
  if review_scores[53].comments == "1"
    code = code + "<li>Focused on unimportant subtopics OR is overly general (mostly common knowledge or the author’s opinion).</li>"
  end
  code = code + "</ul></td>"

  code = code + "<td><ul>"
  if review_scores[54].comments == "1"
    code = code + "<li>Is not relevant to future teachers.</li>"
  end
  if review_scores[55].comments == "1"
    code = code + "<li>Lacks any substantive information (entirely common knowledge or author’s opinion).</li>"
  end
  code = code + "</ul></td></tr>"
  code = code + "</table>"
  code = code + "<h3>Interest</h3>"
  code = code +
           "<div align=\"center\">To attract and maintain attention, the lesson has:</div><table class='general'>
            <tr>
              <th>5 - Extremely Interesting   </th>
              <th>4 - Quite Interesting  </th>
              <th>3 - Reasonably Interesting  </th>
              <th>2 - Little Interest</th>
              <th>1 - No Interest    </th>
            </tr>
            <tr>"

  code = code + "<td><ul>"
  if review_scores[56].comments == "1"
    code = code + "<li>Attractive visuals and engaging interactive elements that effectively help teach the content.</li>"
  end
  if review_scores[57].comments == "1"
    code = code + "<li>Compelling stories or examples that capture the reader’s attention and effectively explain ideas and elaborate on cited material.</li>"
  end
  if review_scores[58].comments == "1"
    code = code + "<li>Examples and/or a discussion of multiple perspectives (pro/con, past/present, teacher/student/parent, etc.).</li>"
  end
  code = code + "</ul></td>"

  code = code + "<td><ul>"
  if review_scores[59].comments == "1"
    code = code + "<li>Attractive visuals and interactive elements that support the content.</li>"
  end
  if review_scores[60].comments == "1"
    code = code + "<li>Stories or examples to illustrate ideas and help interpret and explain cited material.</li>"
  end
  if review_scores[61].comments == "1"
    code = code + "<li>Recognition of multiple perspectives.</li>"
  end
  code = code + "</ul></td>"

  code = code + "<td><ul>"
  if review_scores[62].comments == "1"
    code = code + "<li>An effective visual or interactive element related to the content.</li>"
  end
  if review_scores[63].comments == "1"
    code = code + "<li>Interpretation and explanations of cited material.</li>"
  end
  code = code + "</ul></td>"

  code = code + "<td><ul>"
  if review_scores[64].comments == "1"
    code = code + "<li>Visuals or interactive elements that do not relate to content or that distract from it.</li>"
  end
  if review_scores[65].comments == "1"
    code = code + "<li>Very little interpretation or explanation of cited material.</li>"
  end
  code = code + "</ul></td>"

  code = code + "<td><ul>"
  if review_scores[66].comments == "1"
    code = code + "<li>No visuals or interactive elements.</li>"
  end
  if review_scores[67].comments == "1"
    code = code + "<li>No interpretation or explanation of cited material.</li>"
  end
  code = code + "</ul></td></tr>"
  code = code + "</table>"
  code = code + "<h3>Credibility</h3>"
  code = code +
           "<div align=\"center\">To demonstrate its credibility the lesson:</div><table class='general'>
            <tr>
              <th>5 - Completely Credible   </th>
              <th>4 - Substantial Credibility  </th>
              <th>3 - Reasonable Credibility </th>
              <th>2 - Limited Credibility</th>
              <th>1 - Not Credible   </th>
            </tr>
            <tr>"

  code = code + "<td><ul>"
  if review_scores[68].comments == "1"
    code = code + "<li>Properly cites 5 or more diverse, reputable sources.</li>"
  end
  if review_scores[69].comments == "1"
    code = code + "<li>Provides citations for all presented information.</li>"
  end
  if review_scores[70].comments == "1"
    code = code + "<li>Identifies bias in sources and clearly differentiates between opinion and fact.</li>"
  end
  code = code + "</ul></td>"
  code = code + "<td><ul>"
  if review_scores[71].comments == "1"
    code = code + "<li>Cites 5 diverse, reputable sources with few APA errors.</li>"
  end
  if review_scores[72].comments == "1"
    code = code + "<li>Provides citations for most information.</li>"
  end
  if review_scores[73].comments == "1"
    code = code + "<li>Clearly differentiates between opinion and fact</li>"
  end
  code = code + "</ul></td>"
  code = code + "<td><ul>"
  if review_scores[74].comments == "1"
    code = code + "<li>Cites 5 reputable sources.</li>"
  end
  if review_scores[75].comments == "1"
    code = code + "<li>Supports some claims with citation.</li>"
  end
  if review_scores[76].comments == "1"
    code = code + "<li>Occasionally states opinion as fact.</li>"
  end
  code = code + "</ul></td>"
  code = code + "<td><ul>"
  if review_scores[77].comments == "1"
    code = code + "<li>Cites 4 reputable sources.</li>"
  end
  if review_scores[78].comments == "1"
    code = code + "<li>Has many unsupported claims.</li>"
  end
  if review_scores[79].comments == "1"
    code = code + "<li>Routinely states opinion as fact and fails to acknowledge bias.</li>"
  end
  code = code + "</ul></td>"
  code = code + "<td><ul>"
  if review_scores[80].comments == "1"
    code = code + "<li>Cites 3 or fewer reputable sources.</li>"
  end
  if review_scores[81].comments == "1"
    code = code + "<li>Consists of mostly unsupported claims.</li>"
  end
  if review_scores[82].comments == "1"
    code = code + "<li>Is very biased and contains almost entirely opinions.</li>"
  end
  code = code + "</ul></td></tr>"
  code = code + "</table>"
  code = code + "<h3>Pedagogy</h3>"
  code = code +
           "<div align=\"center\">To help guide the reader:</div><table class='general'>
            <tr>
              <th>5 - Superior   </th>
              <th>4 - Effective  </th>
              <th>3 - Acceptable </th>
              <th>2 - Deficient</th>
              <th>1 - Absent   </th>
            </tr>
            <tr>"

  code = code + "<td><ul>"
  if review_scores[83].comments == "1"
    code = code + "<li>Specific, appropriate, observable learning targets establish the purpose of the lesson.</li>"
  end
  if review_scores[84].comments == "1"
    code = code + "<li>The lesson accomplishes its established goals.</li>"
  end
  if review_scores[85].comments == "1"
    code = code + "<li>Well constructed MC questions (1&2 knowledge; 3&4 application) align with learning targets and assess important content.</li>"
  end
  if review_scores[88].comments == "1"
    code = code + "<li>An anticipatory set engages the reader, introduces the topic and its importance to future teachers, and helps readers connect to the content; the lesson closure synthesizes the material presented and stimulates further thinking on the issue.</li>"
  end
  code = code + "</ul></td>"

  code = code + "<td><ul>"
  if review_scores[87].comments == "1"
    code = code + "<li>Specific and reasonable learning targets are stated.</li>"
  end
  if review_scores[88].comments == "1"
    code = code + "<li>The lesson partially meets its established goals</li>"
  end
  if review_scores[89].comments == "1"
    code = code + "<li>Well constructed MC questions (4) assess important content.</li>"
  end
  if review_scores[90].comments == "1"
    code = code + "<li>An anticipatory set engages the reader and introduces the topic; the lesson ends with a conclusion that summarizes the content.</li>"
  end
  code = code + "</ul></td>"

  code = code + "<td><ul>"
  if review_scores[91].comments == "1"
    code = code + "<li>Reasonable learning targets are stated.</li>"
  end
  if review_scores[92].comments == "1"
    code = code + "<li>The content relates to its goals.</li>"
  end
  if review_scores[93].comments == "1"
    code = code + "<li>MC questions (4) assess important content.</li>"
  end
  if review_scores[94].comments == "1"
    code = code + "<li>An introduction and conclusion are included.</li>"
  end
  code = code + "</ul></td>"

  code = code + "<td><ul>"
  if review_scores[95].comments == "1"
    code = code + "<li>A learning target is included.</li>"
  end
  if review_scores[96].comments == "1"
    code = code + "<li>Content does not achieve its goal, or goal is unclear.</li>"
  end
  if review_scores[97].comments == "1"
    code = code + "<li>4 questions are included.</li>"
  end
  if review_scores[98].comments == "1"
    code = code + "<li>An introduction or a conclusion is included.</li>"
  end
  code = code + "</ul></td>"

  code = code + "<td><ul>"
  if review_scores[99].comments == "1"
    code = code + "<li>Learning target is missing/ not actually a learning target</li>"
  end
  if review_scores[100].comments == "1"
    code = code + "<li>Lesson has no goal/ content is unfocused.</li>"
  end
  if review_scores[101].comments == "1"
    code = code + "<li>Questions are missing.</li>"
  end
  if review_scores[102].comments == "1"
    code = code + "<li>Neither an introduction nor a conclusion are included.</li>"
  end
  code = code + "</ul></td></tr>"
  code = code + "</table>"
  code = code + "<h3>Writing Quality</h3>"
  code = code +
           "<div align=\"center\">The writing:</div><table class='general'>
            <tr>
              <th>5 - Excellently Written   </th>
              <th>4 - Well Written  </th>
              <th>3 - Reasonably Written  </th>
              <th>2 - Fairly Written</th>
              <th>1 - Poorly Written    </th>
            </tr>
            <tr>"

  code = code + "<td><ul>"
  if review_scores[103].comments == "1"
    code = code + "<li>Is focused, organized, and easy to read throughout.</li>"
  end
  if review_scores[104].comments == "1"
    code = code + "<li>Contains no or almost no mechanical errors.</li>"
  end
  code = code + "</ul></td>"

  code = code + "<td><ul>"
  if review_scores[105].comments == "1"
    code = code + "<li>Is organized and flows well.</li>"
  end
  if review_scores[106].comments == "1"
    code = code + "<li>Contains a few minor mechanical errors.</li>"
  end
  code = code + "</ul></td>"

  code = code + "<td><ul>"
  if review_scores[107].comments == "1"
    code = code + "<li>Is mostly organized.</li>"
  end
  if review_scores[108].comments == "1"
    code = code + "<li>Has a few mechanical errors that distract from the content.</li>"
  end
  code = code + "</ul></td>"

  code = code + "<td><ul>"
  if review_scores[109].comments == "1"
    code = code + "<li>Can be difficult to follow.</li>"
  end
  if review_scores[110].comments == "1"
    code = code + "<li>Has several mechanical errors that significantly distract from the content.</li>"
  end
  code = code + "</ul></td>"

  code = code + "<td><ul>"
  if review_scores[111].comments == "1"
    code = code + "<li>Has minimal organization</li>"
  end
  if review_scores[112].comments == "1"
    code = code + "<li>Has many mechanical errors that inhibit comprehension.</li>"
  end
  code = code + "</ul></td></tr>"
  code = code + "</table>"

  #*******************Ratings************************
  code = code + "<h2>Ratings</h2><hr>"

  code = code + "<h3>Importance</h3>"
    code = code + "<i>Grade: </i><b>#{review_scores[113].comments.gsub(/\"/,'&quot;').to_s}</b><br/>"
    code = code + "<i>Comment: </i><dl><dd>#{review_scores[114].comments.gsub(/\"/,'&quot;').to_s}</dl></dd><br/>"

  code = code + "<h3>Interest</h3>"
    code = code + "<i>Grade: </i><b>#{review_scores[115].comments.gsub(/\"/,'&quot;').to_s}</b><br/>"
    code = code + "<i>Comment: </i><dl><dd>#{review_scores[116].comments.gsub(/\"/,'&quot;').to_s}</dl></dd><br/>"

  code = code + "<h3>Credibility</h3>"
    code = code + "<i>Grade: </i><b>#{review_scores[117].comments.gsub(/\"/,'&quot;').to_s}</b><br/>"
    code = code + "<i>Comment: </i><dl><dd>#{review_scores[118].comments.gsub(/\"/,'&quot;').to_s}</dl></dd><br/>"

  code = code + "<h3>Pedagogy</h3>"
    code = code + "<i>Grade: </i><b>#{review_scores[119].comments.gsub(/\"/,'&quot;').to_s}</b><br/>"
    code = code + "<i>Comment: </i><dl><dd>#{review_scores[120].comments.gsub(/\"/,'&quot;').to_s}</dl></dd><br/>"

  code = code + "<h3>Writing Quality</h3>"
    code = code + "<i>Grade: </i><b>#{review_scores[121].comments.gsub(/\"/,'&quot;').to_s}</b><br/>"
    code = code + "<i>Comment: </i><dl><dd>#{review_scores[122].comments.gsub(/\"/,'&quot;').to_s}</dl></dd><br/>"
  rescue
    code += "Error " + $!
  end
  code
end
