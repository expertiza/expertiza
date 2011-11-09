module AssignmentStageHelper

 #has to be here only
  def get_current_stage(topic_id=nil)
    if self.staggered_deadline?
      if topic_id.nil?
        return "Unknown"
      end
    end
    due_date = find_current_stage(topic_id)
    if due_date == nil or due_date == COMPLETE
      return COMPLETE
    else
      return DeadlineType.find(due_date.deadline_type_id).name
    end
  end


  def get_stage_deadline(topic_id=nil)
     if self.staggered_deadline?
        if topic_id.nil?
          return "Unknown"
        end
     end

    due_date = find_current_stage(topic_id)
    if due_date == nil or due_date == COMPLETE
      return due_date
    else
      return due_date.due_at.to_s
    end
  end


def find_current_stage(topic_id=nil)
    if self.staggered_deadline?
      due_dates = TopicDeadline.find(:all,
                   :conditions => ["topic_id = ?", topic_id],
                   :order => "due_at DESC")
    else
      due_dates = DueDate.find(:all,
                   :conditions => ["assignment_id = ?", self.id],
                   :order => "due_at DESC")
    end


    if due_dates != nil and due_dates.size > 0
      if Time.now > due_dates[0].due_at
        return COMPLETE
      else
        i = 0
        for due_date in due_dates
          if Time.now < due_date.due_at and
             (due_dates[i+1] == nil or Time.now > due_dates[i+1].due_at)
            return due_date
          end
          i = i + 1
        end
      end
    end
  end


  def find_next_stage()
    #puts "~~~~~~~~~~Enter find_next_stage()\n"
    due_dates = DueDate.find(:all,
                 :conditions => ["assignment_id = ?", self.id],
                 :order => "due_at DESC")

    if due_dates != nil and due_dates.size > 0
      if Time.now > due_dates[0].due_at
        return COMPLETE
      else
        i = 0
        for due_date in due_dates
          if Time.now < due_date.due_at and
             (due_dates[i+1] == nil or Time.now > due_dates[i+1].due_at)
             if (i > 0)
               return due_dates[i-1]
             else
               return nil
             end
          end
          i = i + 1
        end

        return nil
      end
    end
  end


end