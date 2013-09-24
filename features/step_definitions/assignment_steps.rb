Given /^I am participating in (team|individual) assignment "(\S+)"$/ do |assignment_type,assignment|
  a = Assignment.new
  a.max_team_size=1

  if assignment_type= /^team$/
    a.max_team_size=3
  end

  a.name = assignment
  a.allow_suggestions= true
  a.directory_path = 'test'
  a.spec_location= 'http://'
  a.availability_flag= true
  a.require_signup= true
  a.save

  dropDeadline = DueDate.new
  dropDeadline.assignment_id= a.id
  dropDeadline.deadline_type_id= DeadlineType.find_by_name('drop_topic').id
  dropDeadline.due_at= '2022-12-28 23:09:15'
  dropDeadline.submission_allowed_id= DeadlineRight.find_by_name('OK').id
  dropDeadline.review_allowed_id= DeadlineRight.find_by_name('No').id
  dropDeadline.review_of_review_allowed_id= DeadlineRight.find_by_name('No').id
  dropDeadline.save

  submitDeadline = DueDate.new
  submitDeadline.assignment_id= a.id
  submitDeadline.deadline_type_id = DeadlineType.find_by_name('submission').id
  submitDeadline.due_at= '2022-12-29 23:09:15'
  submitDeadline.submission_allowed_id= DeadlineRight.find_by_name('OK').id
  submitDeadline.review_allowed_id= DeadlineRight.find_by_name('No').id
  submitDeadline.review_of_review_allowed_id= DeadlineRight.find_by_name('No').id
  submitDeadline.save

  reviewDeadline = DueDate.new
  reviewDeadline.assignment_id= a.id
  reviewDeadline.deadline_type_id= DeadlineType.find_by_name('review').id
  reviewDeadline.due_at= '2022-12-30 23:09:15'
  reviewDeadline.submission_allowed_id= DeadlineRight.find_by_name('OK').id
  reviewDeadline.review_allowed_id= DeadlineRight.find_by_name('OK').id
  reviewDeadline.review_of_review_allowed_id= DeadlineRight.find_by_name('No').id
  reviewDeadline.save

  metareviewDeadline = DueDate.new
  metareviewDeadline.assignment_id= a.id
  metareviewDeadline.deadline_type_id = DeadlineType.find_by_name('metareview').id
  metareviewDeadline.due_at= '2022-12-31 23:09:15'
  metareviewDeadline.submission_allowed_id= DeadlineRight.find_by_name('No').id
  metareviewDeadline.review_allowed_id= DeadlineRight.find_by_name('No').id
  metareviewDeadline.review_of_review_allowed_id= DeadlineRight.find_by_name('OK').id
  metareviewDeadline.save

  user = User.find_by_name('student')

  participant = Participant.new
  participant.user_id= user.id
  participant.parent_id= a.id
  participant.submit_allowed= true
  participant.review_allowed= true
  participant.type= "AssignmentParticipant"
  participant.save
end
