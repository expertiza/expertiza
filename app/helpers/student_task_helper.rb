module StudentTaskHelper
  def get_review_grade_info(participant)
    info = ''
    if participant.try(:review_grade).try(:grade_for_reviewer).nil? ||
       participant.try(:review_grade).try(:comment_for_reviewer).nil?
      result = "N/A"
    else
      info = "Score: " + participant.try(:review_grade).try(:grade_for_reviewer).to_s + "/100\n"
      info += "Comment: " + participant.try(:review_grade).try(:comment_for_reviewer).to_s
      info = truncate(info, length: 1500, omission: '...')
      result = "<img src = '/assets/info.png' title = '" + info + "'>"
    end
    result.html_safe
  end

  def check_reviewable_topics(assignment)
    return true if !assignment.topics? and assignment.get_current_stage != "submission"
    sign_up_topics = SignUpTopic.where(assignment_id: assignment.id)
    sign_up_topics.each {|topic| return true if assignment.can_review(topic.id) }
    false
  end

  def unsubmitted_self_review?(participant_id)
    self_review = SelfReviewResponseMap.where(reviewer_id: participant_id).first.try(:response).try(:last)
    return !self_review.try(:is_submitted) if self_review
    true
  end


  def populate_visjs_elements

    current_folder = DisplayOption.new
    current_folder.name = ""

    @href_arr= Array.new
    #<!-- @href_arr is used to store all the hyperlinks for each visualized object -->
    @duedates = DueDate.where("parent_id = #{@assignment.id}")
    @visualization_data = @duedates.map do |due|
      @href_arr.push(""); #empty hyperlink as we do not provide hyperlinks for submissions/reviews
      if due.deadline_type_id.eql? 1
        { :id => due.id, :start=> due.due_at, :className => "submissionDue", :content => "Round "+(due.round.to_s)+"<split>Submission due by "+'<br>'+due.due_at.strftime("%m/%d/%Y at %I:%M %p") }
      else
        { :id => due.id, :start=> due.due_at, :className => "reviewDue", :content => "Round "+(due.round.to_s)+"<split>Review due by "+'<br>'+due.due_at.strftime("%m/%d/%Y at %I:%M %p") }
      end
    end


    #<!-- display only if submissions are made-->
    unless @team.nil?
      @submissions = SubmissionRecord.find_by_sql"select * from  submission_records where assignment_id=#{@assignment.id} and team_id=#{@team.id} and content NOT IN (select content from submission_records where assignment_id=#{@assignment.id} and team_id=#{@team.id} and UPPER(operation) Like 'REMOVE%')"

      @visualization_data += @submissions.map do |submission|
        #display_directory_tree(participant, files, true).html_safe
        if (submission.operation).eql?('Submit File')
          file = submission.content
          ret=""
          if File.exist?(file) && File.directory?(file)
            ret += link_to File.basename(file), :controller => 'submitted_content', :action => 'edit', :id => participant.id, "current_folder[name]" => file
          else
            ret += "\n      "
            ret += link_to File.basename(file), :controller => 'submitted_content',
                           :action => 'download',
                           :id => @participant.id,
                           :download => File.basename(file),
                           "current_folder[name]" => File.dirname(file)
          end
          @href_arr.push(ret.split('"')[1])
          #only file name instead of entire relative path need to be displayed on timeline. Hence we push the same in content, appending created time to it
          { :id => submission.id, :start=> submission.created_at, :className=> "fileUpload", :content => (submission.content).split('/')[-1]+'<split>'+submission.created_at.strftime("%m/%d/%Y at %I:%M %p") }
        else
          @href_arr.push(submission.content)
          { :id => submission.id, :start=> submission.created_at, :className=> "hyperlinkUpload" ,:content => submission.content+'<split>'+submission.created_at.strftime("%m/%d/%Y at %I:%M %p") }
        end
      end

    end

    #<!-- Reviews not yet started -->
    unless @review_mappings.nil?
      @review_mappings.each do |review_mapping_iterator|
        @response_values = Response.where(:map_id => review_mapping_iterator.id)
        @visualization_data += @response_values.map do |response_value_iterator|
          if review_mapping_iterator.type=="ReviewResponseMap"
            review_mapping = ResponseMap.find(review_mapping_iterator.reviewed_object_id)
            participant = AssignmentTeam.get_first_member(review_mapping_iterator.reviewee_id)
            topic_id = SignedUpTeam.topic_id(participant.parent_id, participant.user_id)
            if !topic_id.nil?
              if SignUpTopic.find(topic_id).topic_identifier != ''
                @topic_name=SignUpTopic.find(topic_id).topic_identifier+": "+SignUpTopic.find(topic_id).topic_name
              else
                @topic_name=SignUpTopic.find(topic_id).topic_name
              end
            end
            unless response_value_iterator.nil? and response_value_iterator.is_submitted.zero?
              @href_arr.push("../response/view?id="+response_value_iterator.id.to_s)
              puts @topic_name
              @topic_name="#{@topic_name}".gsub("'", %q()) #look for single quotes in topic names and remove them as they will interfere with JS parser
              puts @topic_name
              { :id => response_value_iterator.id, :start=> response_value_iterator.created_at, :className => "review", :content => "Peer Review - Round "+response_value_iterator.round.to_s+"<split> Review for: #{@topic_name}"+'<br>'+response_value_iterator.created_at.strftime("%m/%d/%Y at %I:%M %p") }
            end
          elsif review_mapping_iterator.type=="SelfReviewResponseMap"
            unless response_value_iterator.nil? and response_value_iterator.is_submitted.zero?
              @href_arr.push("../response/view?id="+response_value_iterator.id.to_s)
              { :id => response_value_iterator.id, :start=> response_value_iterator.created_at, :className => "selfReview", :content => "Self Review - Round "+response_value_iterator.round.to_s+"<split>Self Review"+'<br>'+response_value_iterator.created_at.strftime("%m/%d/%Y at %I:%M %p") }
            end
          elsif review_mapping_iterator.type=="TeammateReviewResponseMap"
            unless response_value_iterator.nil? and response_value_iterator.is_submitted.zero?
              reviewee = ResponseMap.where(:reviewer_id => "#{review_mapping_iterator.reviewer_id}", :id =>"#{review_mapping_iterator.id}").pluck(:reviewee_id)
              puts reviewee.to_s+" "+review_mapping_iterator.reviewer_id.to_s+" "+review_mapping_iterator.id.to_s
              user_id = Participant.where(:id=> "#{reviewee[0]}").pluck(:user_id)
              reviewee_name = User.where(:id=>"#{user_id[0]}").pluck(:name)
              @href_arr.push("../response/view?id="+response_value_iterator.id.to_s)
              { :id => response_value_iterator.id, :start=> response_value_iterator.created_at, :className => "teamReview", :content => "Team Review - Round "+response_value_iterator.round.to_s+"<split>Team review for #{reviewee_name[0]}"+'<br>'+response_value_iterator.created_at.strftime("%m/%d/%Y at %I:%M %p") }
            end
          else
            unless response_value_iterator.nil? and response_value_iterator.is_submitted.zero?
              @href_arr.push("../response/view?id="+response_value_iterator.id.to_s)
              { :id => response_value_iterator.id, :start=> response_value_iterator.created_at, :className => "feedback", :content => "Feedback - Round "+response_value_iterator.round.to_s+"<split>Feedback"+'<br>'+response_value_iterator.created_at.strftime("%m/%d/%Y at %I:%M %p") }
            end
          end
        end
      end
    end
  end

end
