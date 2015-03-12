module ReviewCommentsHelper

  def self.construct_comments_table(comment_array,comment_window,i,initial_line_number,final_line_number,authorflag,selectedFile)
    #return "" unless comment_array.length > 0

    #comment_window_html = "<table width='100%' cellpadding='3' style='table-layout: fixed; word-wrap: break-word;'>"
    comment_window_html = comment_window
    # for i in 0..(comment_array.length-1) do
    if initial_line_number == final_line_number
      comment_window_html += "<tr><td><hr><b>Comment for line #{initial_line_number + 1}:</b><br/><font color='blue'>" +
        comment_array            #New code---------

    else
      comment_window_html += "<tr><td><hr><b>Comment for lines #{initial_line_number + 1} - #{final_line_number + 1}:</b><br/><font color='blue'>" +
        comment_array            #New code---------
      end
    if authorflag == 0
      comment_window_html +=  "</font></td></tr>"
    else
      if "old" == selectedFile
        # comment_window_html += "<tr><td><hr><b>Comment for lines #{initial_line_number + 1} - #{final_line_number + 1}:</b><br/><font color='blue'>" +
        #    comment_array
        comment_window_html += "</font></td></tr>"
      else
        comment_window_html +=  "<br><br><a id ='#{i+1}' onclick=\"createButton('#{i}','#{initial_line_number}','#{final_line_number}')\"><b>Reply</b></a></td></tr>"
      end
    end
    # comment_window_html += "</table>"
    return comment_window_html
    end

  def self.construct_bookmarks_table(bookmark_array)
    comment_window_html = "<table width='100%' cellpadding='3' style='table-layout: fixed; word-wrap: break-word;'>"
    bookmark_array.each do |bookmark|

      #onclick="if(checkMouseDown(event,id)){ createComments('<%= (i) %>','<%= (i+1) %>', '<%=@shareObj['offsetarray2'][i]%>', '<%=@current_review_file.id %>')}"
      comment_window_html += "<tr onclick=\"createComments('#{bookmark.initial_line_number}','#{bookmark.initial_line_number}', '#{bookmark.file_offset}', '#{bookmark.review_file_id}')\"><td><b>Comments for Lines #{bookmark.initial_line_number}' to '#{bookmark.last_line_number}'</b><br/>" +
        + "</td></tr>"
    end
    comment_window_html += "</table>"
    return comment_window_html

  end

  def self.populate_comments(params, authorflag, comment)
    assignmentparticipant = AssignmentParticipant.find(params[:participant_id])
    current_participant = AssignmentParticipant.where(parent_id: assignmentparticipant[:parent_id], user_id: session[:user].id).first

    if current_participant.id.to_s == params[:participant_id]
      authorflag = 1
    else
      authorflag = 0
    end

    member = []
    if assignmentparticipant.assignment.team_assignment
      assignmentparticipant.team.get_participants.each_with_index {|member1, index|

        member[index] = member1.id
      }
    end

    if (comment[:reviewer_participant_id] ==  current_participant.id)
      handle = "Me :"
      authorflag = 0
    elsif member.include? comment[:reviewer_participant_id] || comment[:reviewer_participant_id] == assignmentparticipant.id
      handle = "Author :"
      authorflag = 0
    else
      handle = "Reviewer"+comment[:reviewer_participant_id].to_s
    end

    return handle, comment, authorflag

  end



  end

