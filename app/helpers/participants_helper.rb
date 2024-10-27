module ParticipantsHelper
  # separates the file into the necessary elements to create a new user
  def self.upload_users(filename, session, params, home_page)
    users = []
    File.open(filename, 'r') do |infile|
      while (rline = infile.gets)
        config = get_config
        attributes = define_attributes(rline.split(config['dlm']), config)
        users << define_user(attributes, session, params, home_page)
      end
    end
    users
  end

  def self.define_attributes(line_split, config)
    attributes = {}
    attributes['role_id'] = Role.find_by name: 'Student'
    attributes['username'] = line_split[config['username'].to_i]
    attributes['fullname'] = config['fullname']
    attributes['email'] = line_split[config['email'].to_i]
    attributes['password'] = (0...8).map { (65 + rand(26)).chr }.join
    attributes['email_on_submission'] = 1
    attributes['email_on_review'] = 1
    attributes['email_on_review_of_review'] = 1
    attributes
  end

  def self.define_user(attrs, session, params, home_page)
    user = User.find_by(username: attrs['username'])
    user = create_new_user(attrs, session) if user.nil?
    if !params[:course_id].nil?
      participant = add_user_to_course(params, user)
    elsif !params[:assignment_id].nil?
      participant = add_user_to_assignment(params, user)
    end
    participant.email(attrs['password'], home_page) unless participant.nil?
    user
  end

  def self.create_new_user(attrs, session)
    user = User.new
    user.update_attributes attrs
    user.parent_id = (session[:user]).id
    user.save
    user
  end

  def self.add_user_to_assignment(params, user)
    assignment = Assignment.find params[:assignment_id]
    if AssignmentParticipant.where('user_id = ? AND parent_id = ?', user.id, assignment.id).empty?
      return AssignmentParticipant.create(parent_id: assignment.id, user_id: user.id)
    end
  end

  def self.add_user_to_course(params, user)
    if CourseParticipant.where('user_id = ? AND parent_id = ?', user.id, params[:course_id]).empty?
      CourseParticipant.create(user_id: user.id, parent_id: params[:course_id])
    end
  end

  def self.get_config
    config = {}
    cfgdir = Rails.root + '/config/'
    File.open(cfgdir + 'roster_config', 'r') do |infile|
      while (line = infile.gets)
        store_item(line, 'dlm', config)
        store_item(line, 'username', config)
        store_item(line, 'fullname', config)
        store_item(line, 'email', config)
      end
    end
    config
  end

  def self.store_item(line, ident, config)
    line_split = line.split('=')
    if line_split[0] == ident
      newstr = line_split[1].sub!("\n", '')
      config[ident] = newstr.strip unless newstr.nil?
    end
  end

  # Authorizations are participant, reader, reviewer, submitter (They are not store in Participant table.)
  # Permissions are can_submit, can_review, can_take_quiz.
  # Get permissions form authorizations.
  def participant_permissions(authorization)
    can_submit = true
    can_review = true
    can_take_quiz = true
  #E2351 pass duty field to match implementation
    can_mentor = false
    case authorization
    when 'reader'
      can_submit = false
      can_review = true
      can_take_quiz = true
    when 'reviewer'
      can_submit = false
      can_review = true
      can_take_quiz = false
    when 'submitter'
      can_submit = true
      can_review = false
      can_take_quiz = false
  #E2351 - adding a 4th option for mentor, permissions are same as participant but has additional permission 'can_mentor'
  #maintained as a boolean like other permissions
    when 'mentor'
      can_submit = true
      can_review = true
      can_take_quiz = true
      can_mentor = true
  #end 2351 changes
    else
      can_submit = true
      can_review = true
      can_take_quiz = true
      can_mentor = false
    end
    { can_submit: can_submit, can_review: can_review, can_take_quiz: can_take_quiz, can_mentor: can_mentor }
  end
end
