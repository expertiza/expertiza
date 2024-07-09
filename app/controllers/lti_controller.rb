class LtiController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:launch]
  skip_before_action :authorize, only: [:launch]

  puts "Load Path:"
  puts $LOAD_PATH

  puts "Gem Path:"
  puts Gem.path

  puts "Trying to require 'ims/lti'..."
  require 'ims/lti'
  puts "Successfully required 'ims/lti'"

  puts "IN LTI_CONTROLLER"
  Rails.logger.debug "IN LTI_CONTROLLER"

  def launch
    puts "IN LAUNCH"
    Rails.logger.debug "IN LAUNCH"
    # render plain: "LTI Launch Received", status: 200

    begin

      # tp = IMS::LTI::ToolProvider.new(
      #   ENV['LTI_KEY'],
      #   ENV['LTI_SECRET'],
      #   params
      # )
      authenticator = IMS::LTI::Services::MessageAuthenticator.new(
        request.url,
        request.request_parameters,
        Rails.application.secrets.LTI_SHARED_SECRET
      )
      puts "LTI SECRET: #{Rails.application.secrets.LTI_SHARED_SECRET}"
      #Check if the signature is valid
      return false unless
      if authenticator.valid_signature?
        puts "VALID LTI SIGNATURE"
        Rails.logger.debug "VALID LTI SIGNATURE"
      #   user = User.find_or_create_by(email: tp.lis_person_contact_email_primary) do |u|
      #     u.name = tp.lis_person_name_full
      #     u.role = tp.roles.first
      #   end

      #   session[:user_id] = user.id
      #   session[:context_id] = tp.context_id
      #   session[:lti_launch_params] = params.to_unsafe_h

      #   Rails.logger.info "LTI Launch successful for user: #{user.email}"

        # sign_in(user)
        # redirect_to root_path, notice: 'Logged in successfully via LTI'
      else
        # Rails.logger.warn "Invalid LTI request"
        # render plain: "Invalid LTI request", status: 401
        puts "NOT A VALID LTI SIGNATURE"
        Rails.logger.debug "NOT A VALID LTI SIGNATURE"
      end
    rescue NameError => e
      Rails.logger.error "NameError in LTI launch: #{e.message}"
      # render plain: "Error processing LTI launch", status: 500
    rescue => e
      Rails.logger.error "Error in LTI launch: #{e.message}"
      # render plain: "Error processing LTI launch", status: 500
    end
  end
end
