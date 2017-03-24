#lti start
include Lti2Commons
include Signer
include MessageSupport
include OAuth::OAuthProxy
#lti end
class ApplicationController < ActionController::Base
  include AccessHelper

  if Rails.env.production?
    # forcing SSL only in the production mode
    force_ssl
  end

  helper_method :current_user_session, :current_user, :current_user_role?
  # protect_from_forgery with: :exception
  before_action :set_time_zone
  # before_action :authorize

  def self.verify(_args)
  end

  def current_user_role?
    current_user.role.name
  end

  def current_role_name
    current_role.try :name
  end

  def current_role
    current_user.try :role
  end

  helper_method :current_user_role?

  def user_for_paper_trail
    session[:user].try :id if session[:user]
  end

  def undo_link(message)
    @version = Version.where(['whodunnit = ?', session[:user].id]).last
    if @version.try(:created_at) && Time.now - @version.created_at < 5.0
      @link_name = params[:redo] == "true" ? "redo" : "undo"
      message += "<a href = #{url_for(controller: :versions, action: :revert, id: @version.id, redo: !params[:redo])}>#{@link_name}</a>"
    end
  end

  private

  def current_user
    @current_user ||= session[:user]
  end
  helper_method :current_user

  def current_user_role
    current_user.role
  end
  alias current_user_role? current_user_role

  def logged_in?
    current_user
  end

  def redirect_back(default = :root)
    redirect_to request.env['HTTP_REFERER'] ? :back : default
  end

  def set_time_zone
    Time.zone = current_user.timezonepref if current_user
  end

  private

  def require_user
    invalid_login_status('in') unless current_user
  end

  def require_no_user
    invalid_login_status('out') if current_user
  end

  def invalid_login_status(status)
    flash[:notice] = "You must be logged #{status} to access this page!"
    redirect_back
  end

  def is_available(user, owner_id)
    user.id == owner_id ||
      user.admin? ||
      user.super_admin?
  end

  protected

  def set_up_display_options(object_type)
    # Create a set that will be used to populate the dropbox when a user lists a set of objects (assgts., questionnaires, etc.)
    # Get the Instructor::QUESTIONNAIRE constant
    @display_options ||= eval "#{current_user_role.class}::#{object_type}"
    end

  # Use this method to validate the current user in order to avoid allowing users
  # to see unauthorized data.
  # Ex: return unless current_user_id?(params[:user_id])
  def current_user_id?(user_id)
    current_user.try(:id) == user_id
  end

  def denied(reason = nil)
    if reason
      redirect_to "/denied?reason=#{reason}"
    else
      redirect_to "/denied"
    end
  end

  #lti start

  def pre_process_tenant
    error_code, message = nil;
    oauth_params = OAuth::OAuthProxy::OAuthRequest.parse_authorization_header request.authorization
    oauth_consumer_key = oauth_params[:oauth_consumer_key] || params['oauth_consumer_key']

    # OAuth check here
    tool_provider_registry = Rails.application.config.tool_provider_registry

    key = oauth_consumer_key
    unless key
      if is_parameters_in_flash
        # no oauth_consumer_key but but flash has been saved from *last* request
        return
      else
        error_code = "LTI_INVALID_REQUEST"
        message = "Improper LTI context: LTI Consumer key is missing or not valid!"
        return [error_code, message];
      end
    end
    @tenant = Tenant.where(:tenant_key => key).first
    @registration = Lti2Tp::Registration.where(:tenant_id => @tenant.id).first
    unless @registration
      error_code = "LTI_INVALID_CONSUMER"
      message = "Tool registration not found. Please register Expertiza in your LMS before invoking the request."
      return [error_code, message];
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

  protected

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
      if ['learner','instructor'].include?(role)
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

  def restore_request_parameters_from_flash
    request[:lti_context] = flash[:lti_context]
  end

  def save_request_parameters_to_flash
    flash[:lti_context] = request.parameters.dup
  end

  def restore_request_parameters_from_session
    request[:lti_context] = session[:lti_context]
    session[:lti_context] = nil
  end

  def save_request_parameters_to_session
    session[:lti_context] = request.parameters.dup
  end

  #lti end

  private

  def record_not_found
    redirect_to controller: :tree_display, action: :list
  end
end
