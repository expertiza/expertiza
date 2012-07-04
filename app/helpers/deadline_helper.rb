module DeadlineHelper

  def create_topic_deadline(due_date, offset, topic_id)
    topic_deadline = TopicDeadline.new
    topic_deadline.topic_id = topic_id
    topic_deadline.due_at = DateTime.parse(due_date.due_at.to_s) + offset.to_i
    topic_deadline.deadline_type_id = due_date.deadline_type_id
    topic_deadline.late_policy_id = due_date.late_policy_id
    topic_deadline.submission_allowed_id = due_date.submission_allowed_id
    topic_deadline.review_allowed_id = due_date.review_allowed_id
    topic_deadline.resubmission_allowed_id = due_date.resubmission_allowed_id
    topic_deadline.rereview_allowed_id = due_date.rereview_allowed_id
    topic_deadline.review_of_review_allowed_id = due_date.review_of_review_allowed_id
    topic_deadline.round = due_date.round
    topic_deadline.save
  end

  def set_start_due_date(assignment_id,set_of_topics)

    #Remember, in create_common_start_time_topics function we reversed the graph so reverse it back
    set_of_topics = set_of_topics.reverse

    set_of_topics_due_dates = Array.new
    i=0
    days_between_submissions = Assignment.find(assignment_id)['days_between_submissions'].to_i
    set_of_topics.each { |set_of_topic|
      set_of_due_dates = nil
      if i==0
        #take the first set from the table which user stores
        set_of_due_dates = DueDate.find_all_by_assignment_id(assignment_id)
        offset = 0
      else
        set_of_due_dates = TopicDeadline.find_all_by_topic_id(set_of_topics[i-1][0])

        set_of_due_dates.sort! {|a,b| a.due_at <=> b.due_at}

        offset = days_between_submissions
      end

      set_of_topic.each { |topic_id|
        #if the due dates have already been created and the save dependency is being clicked,
        #then delete existing n create again
        prev_saved_due_dates = TopicDeadline.find_all_by_topic_id(topic_id)

        #Only if there is a dependency for the topic
        if !prev_saved_due_dates.nil?
          num_due_dates = prev_saved_due_dates.length
          #for each due date in the current topic he want to compare it to the previous due date
          for x in 0..num_due_dates - 1
            #we don't want the old date to move earlier in time so we save it as the new due date and destroy the old one
            if DateTime.parse(set_of_due_dates[x].due_at.to_s) + offset.to_i < DateTime.parse(prev_saved_due_dates[x].due_at.to_s)
              set_of_due_dates[x] = prev_saved_due_dates[x]
              offset = 0
            end
            prev_saved_due_dates[x].destroy
          end
        end

        set_of_due_dates.each {|due_date|
          create_topic_deadline(due_date, offset, topic_id)
        }
      }
      i = i+1
    }

  end
end
