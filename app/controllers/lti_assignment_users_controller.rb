include Lti2Commons
include Signer
include MessageSupport
include OAuth::OAuthProxy
class LtiAssignmentUsersController < ApplicationController
  protect_from_forgery :except => :create

  def action_allowed?
    case params[:action]
      when 'create', 'back_to_lms'
        return true
    end
  end

  def create
    (@error_code, @message) = pre_process_tenant
    if @error_code == 200 # 200 means pre processing was successful
      (user, @error_code, @message) = lti_login()
      if(user)
        assignment_id = params['custom_assignment_id'] # assignment_id needs to be passed as a
        assignment = Assignment.find(assignment_id)
        if assignment
          # Assignment number passed in the request is valid.
          assignment_participant = AssignmentParticipant.find_by_user_id_and_assignment_id(user.id,assignment_id)
          lis_result_sourcedid = params["lis_result_sourcedid"]; # sourcedid is used to send grades back
          @tenant.lis_outcome_service_url = params['lis_outcome_service_url'];
          unless assignment_participant
            # Assignment_Participant not found in participant table and assignment exists. So add user to participant table.
            assignment.add_participant_by_user(user, true, true, true) # By default, set can_review, can_quiz, can_submit as true
            assignment_participant = AssignmentParticipant.find_by_user_id_and_assignment_id(user.id, assignment_id)
          end
          if lis_result_sourcedid and @tenant.lis_outcome_service_url
            # Add participant, assignment to LtiAssignmentUser table for enabling "grade passback" feature
            # LtiAssignmentUser is a mapping of the sourcedid's with Expertiza assignment and user
            ua = LtiAssignmentUser.find_by_participant_id assignment_participant # LtiAssignmentUser already exist for participant, so just update.
            if ua == nil
              ua = LtiAssignmentUser.new
            end
            ua.assignment_id = assignment_id;
            ua.user_id = user.id;
            ua.participant_id = assignment_participant.id;
            ua.lis_result_source_did = lis_result_sourcedid;
            ua.tenant_id = @tenant.id;
            ua.save; # Will be used later to post grades back.
            @tenant.save;
          end
          redirect_to "/student_task/view?id=#{assignment_participant.id}" # Redirect to the assignment viewing page for the user
        else
          @message = "Assignment number in the request is invalid"
          @error_code = "LTI_CUSTOM_PARAMETER_INVALID"
        end
      end
    end
    if(@error_code != 200)
      @url = params['launch_presentation_return_url'];
      flash[:notice] = @message
    end
  end

  def back_to_lms
    (redirect_to (params['url']))
  end

  private

  def define_attributes
    attributes = {}
    attributes["role_id"] = Role.student.id
    attributes["email"] = params['lis_person_contact_email_primary']
    # The user's name is set as the initial part of the email address.
    attributes["name"] =  attributes["email"].split("@")[0] if attributes["email"] != nil?
    attributes["fullname"] = params['lis_person_name_given']
    attributes["email_on_submission"] = 1
    attributes["email_on_review"] = 1
    attributes["email_on_review_of_review"] = 1
    attributes
  end

  def create_new_user(attributes)
    user = User.new(attributes)
    user.parent_id = 2 #Set super-admin id as parent for now
    user.timezonepref = User.find(user.parent_id).timezonepref
    user.save!
    user
  end

  # Authenticates the user who has requested the Expertiza resource.
  # Since user is coming from an authentic source like Moodle, user is auto-created if does not already exist.
  def lti_login
    error_code = nil
    message = nil
    user = User.find_by_login(params['lis_person_contact_email_primary'])
    if user == nil
      attributes = define_attributes()
      user = create_new_user(attributes)
    end
    if user
      if(current_user!=nil && current_user.id!=user.id) # Clear session if different user's session is going on
        AuthController.clear_session(session)
      end
      if(session[:user] == nil) # Create new session with new user if no current session exists
        session[:user] = user
      end
      AuthController.set_current_role(user.role_id, session)
      return [user,error_code,message]
    else
      if(session[:user]!=nil) # If new user is not found, then clear existing session
        AuthController.clear_session(session)
      end
      error_code = "LTI_USER_NOT_FOUND"
      message = "User not registered on Expertiza. Please contact Expertiza administrators for registration details"
      return [user,error_code,message]
    end
    return [user,error_code,message]
  end # def login

  # Checks the authenticity of the tenant, i.e. LMS like moodle, using the request data
  def pre_process_tenant
    error_code, message = nil
    oauth_params = OAuth::OAuthProxy::OAuthRequest.parse_authorization_header request.authorization
    oauth_consumer_key = oauth_params[:oauth_consumer_key] || params['oauth_consumer_key']

    # OAuth check here
    tool_provider_registry = Rails.application.config.tool_provider_registry

    key = oauth_consumer_key
    unless key
      error_code = "LTI_INVALID_REQUEST"
      message = "Improper LTI context: LTI Consumer key is missing or not valid!"
      return [error_code, message]
    end
    @tenant = Lti_Tenant.where(:tenant_key => key).first
    @registration = Lti2Tp::Registration.where(:tenant_id => @tenant.id).first
    unless @registration
      error_code = "LTI_INVALID_CONSUMER"
      message = "Tool registration not found. Please register Expertiza in your LMS before invoking the request."
      return [error_code, message]
    end

    request.parameters['_tenant_id'] = @tenant.id

    tool_proxy = JsonWrapper.new(@registration.tool_proxy_json)
    secret = @tenant.secret

    unless tool_provider_registry.relaxed_oauth_check == 'true'
      request_wrapper = OAuthRequest.create_from_rack_request request
      (is_success, signature_base_string) = request_wrapper.verify_signature? secret, Rails.application.config.nonce_cache
      unless is_success
        puts "TP Secret: #{secret}"
        puts "TP Signed Request: #{request_wrapper.signature_base_string}"
        (redirect_to redirect_url("Invalid signature")) and return
      end
      request[:lti_context] = request.parameters
    end

    # LTI conformance
    # Perform extra LTI type checks only for launch
    if params['lti_message_type']  == 'basic-lti-launch-request'
      if params.has_key?('lti_message_type')
        lti_message_type = params['lti_message_type']
        unless ['basic-lti-launch-request', 'ToolProxyRegistrationRequest', 'ToolProxyReregistrationRequest'].include?(lti_message_type)
          (redirect_to redirect_url("Invalid lti_message_type: #{lti_message_type}")) and return
        end
      else
        (redirect_to redirect_url("Missing lti_message_type")) and return
      end

      if params['lti_message_type'] == 'basic-lti-launch-request'
        request.request_parameters['normalized_role'] = normalize_role(params['roles'])
        unless params.has_key?('resource_link_id')
          (redirect_to redirect_url("Missing resource link id")) and return
        end

        if params.has_key?('lti_version')
          lti_version = params['lti_version']
          unless ['LTI-1p0', 'LTI-2p0'].include?(lti_version)
            (redirect_to redirect_url("Invalid lti_version: #{lti_version}")) and return
          end
        else
          (redirect_to redirect_url("Missing lti_version")) and return
        end
      end
    end

    return [200, nil, nil]
  end


  def lti_assignment_user_params
      params.require(:lti_assignment_user).permit(:user_id, :assignment_id, :participant_id, :lis_result_source_did, :tenant_id, :grade)
  end

  def normalize_role(roles_string)
    roles_string ||= 'learner'
    roles = roles_string.downcase.split(',')
    regex = /[\/#](\w+)$/
    roles.each do |full_role|
      # allow old urn form or new uri form
      m = regex.match(full_role)
      if m.nil?
        role = full_role
      else
        role = m[1]
      end
      if ['learner', 'instructor'].include?(role)
        return role
      end
    end
    'learner'
  end

  def redirect_url(msg)
    msg = Rack::Utils.escape(msg)
    "#{params['launch_presentation_return_url']}?status=failure&lti_errormsg=#{msg}&lti_errorlog=#{msg}"
  end

  def is_parameters_in_flash
    not flash[:lti_context].nil?
  end

end