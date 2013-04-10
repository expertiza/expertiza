Given /^I am participating on assignment "(\S+)"$/ do |assignment|
  a = Assignment.new
  a.name = assignment
  a.team_count= 2
  a.allow_suggestions= true
  a.directory_path = 'test'
  a.spec_location= 'http://'
  a.availability_flag=true
  a.team_assignment=true
  a.save

  submitDate = DueDate.new
  submitDate.assignment_id= a.id
  submitDate.deadline_type_id = DeadlineType.find_by_name('submission').id
  submitDate.due_at= '2011-12-30 23:09:15'

  reviewDeadline = DueDate.new
  reviewDeadline.assignment_id= a.id
  reviewDeadline.deadline_type_id= DeadlineType.find_by_name('review').id
  reviewDeadline.due_at= '2022-12-30 23:09:15'

  dropDeadline = DueDate.new
  dropDeadline.assignment_id= a.id
  dropDeadline.deadline_type_id= DeadlineType.find_by_name('drop_topic').id
  dropDeadline.due_at= '2022-12-30 23:09:15'
  
  user = User.find_by_name("student")

  participant = Participant.new
  participant.user_id= user.id
  participant.parent_id= a.id
  participant.submit_allowed= true
  participant.review_allowed= true
  participant.type= "AssignmentParticipant"
  participant.save!
end
