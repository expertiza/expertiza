module GradeInterfaceHelperSpec
  def set_deadline_type
    create(:deadline_type, name: "submission")
    create(:deadline_type, name: "review")
    create(:deadline_type, name: "metareview")
    create(:deadline_type, name: "drop_topic")
    create(:deadline_type, name: "signup")
    create(:deadline_type, name: "team_formation")
  end

  def set_deadline_right
    create(:deadline_right)
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')
  end

  def set_assignment_due_date
    create(:assignment_due_date)
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'review').first, due_at: Time.now.in_time_zone + 1.day)
  end

  def assignment_setup
    create(:assignment)
    create_list(:participant, 3)
    create(:assignment_node)
    set_deadline_type
    set_deadline_right
    set_assignment_due_date
  end
end
