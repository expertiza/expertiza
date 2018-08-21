# added the badges controller as part of E1822
# added a create method for badge creation functionality
class BadgesController < ApplicationController
  require 'json'
  require 'rest-client'
  require 'base64'
  require 'open-uri'

  # this should be fetched from a table and we need an UI to populate instructor's access_token;
  #@@access_token = "85d2e67ea0956aa7825e98ed9037f6c4627b593d28e537a9a7f1804b038b30dbf4b0544a68182f3d384e8aefb07e441a4abcac3100fb122b75491d1b816daa6e"
  @@x_api_key = "ce56ea802fdee803531c310e30b0e32c"
  @@x_api_secret = "fXYe3lH8xN62mvj5K8AuCmw2Ca7SQcIekvftil1aVFhKQcQuMLmjqqC6/hr1x4SlV9TfHSQxWdvZ+K0bUnCxmBXLYMrGSnigU22fy26thaH6u6duNoZX/4qx+y9iLYa/jotMe5X1GNom+230nw2hLqPH0EiIotZ0t+5TUWl5cvU="

  def action_allowed?
    ['Instructor',
     'Teaching Assistant',
     'Administrator',
     'Super-Administrator'].include? current_role_name
  end

  def new
    tokens = UserCredlyToken.where(user_id: current_user.id)
    if tokens.count < 1
      render action: 'login_credly'
    end
  end

  def redirect_to_assignment
    redirect_to session.delete(:return_to)
  end

  def create
    # in development mode, open() can't open files hosted by thin web server
    result = nil
    if Rails.env.development?
      Thread.new do
        do_create_badge
      end
    else
      do_create_badge
    end



    # need to return to whatever the starting point was
    redirect_to :action => 'new'
  end

  def do_create_badge
    result = create_badge_in_credly
    # save badge info in local db

    newBadge = Badge.new(:name => params['badge']['name'],
              :description => params['badge']['description'],
              :image_name => params['image-icon'],
              :instructor_id => current_user.id,
              :private => !params['badge']['private'],
              :external_badge_id => result['data'].to_i)
    newBadge.save

  end

  def create_badge_in_credly
    tokens = UserCredlyToken.where(user_id: current_user.id).last

    # maybe save the image file, so we can grab the ones created with credly designer
    file_url = params['image-icon'];
    file_name = file_url.split('/')[-1]
    image_file = open(file_url)
    directory = get_icon_directory_path
    IO.copy_stream(image_file, directory + file_name) unless File.file?(directory + file_name)

    # convert image to
    image_icon = Base64.encode64(image_file.read)
    form_data = {:title => params['badge']['name'],
                 :attachment => image_icon,
                 :short_description => params['badge']['description'],
                 :is_giveable => true,
                 :is_claimable => false,
                 :expires_in => 0,
                 :multipart => true}
    headers = {"X-Api-Key": @@x_api_key,
               "X-Api-Secret": @@x_api_secret}
    url = "https://api.credly.com/v1.1/badges?access_token=" + tokens.access_token
    response = RestClient.post(url, form_data, headers=headers)

    return JSON.parse(response.to_str)
  end

  def icon_upload
    if params['fileupload'].content_type.include? "image"
      name = params['fileupload'].original_filename
      directory = get_icon_directory_path
      # create dir
      FileUtils::mkdir_p(directory) unless File.exists?(directory)
      # create the file path
      path = File.join(directory, name)
      if File.exists?(path)
        name.chomp!(File.extname(path))
        name += "_" + Time.now.strftime("%d_%m_%Y__%H_%M") + File.extname(path)
        path = File.join(directory, name)
      end
      # write the file
      File.open(path, "wb") { |f| f.write(params['fileupload'].read) }
    end
    file_url = request.protocol + request.host_with_port + "/assets/badges/" + current_user.id.to_s + "/" + name
    render status: 200, json: {status: 200, message: "file uploaded", fileurl: file_url, filename: name}.to_json
  end

  def icons
    directory = get_icon_directory_path
    image_icons = Dir.entries(directory).reject {|f| File.directory?(f) || f[0].include?('.')}
    render status: 200, json: image_icons.map{|f| request.protocol + request.host_with_port + "/assets/badges/" + current_user.id.to_s + "/" + f}
  end

  def get_icon_directory_path()
    directory = Rails.root.join('app', 'assets', 'images', 'badges', current_user.id.to_s)
  end

  # def list
  #   @instructor_id = params[:id]
  #   @badges = Badge.where(instructor_id: @instructor_id)
  #               .or(Badge.where(private: 0)).to_a
  #   @badges.sort_by{|b| b.instructor_id == @instructor_id}
  # end

  def upload_evidence
    participant = Participant.find_by_id(params[:id])
    @assignment_badges = AwardedBadge.where(pariticpant_id: pariticpant.id, approval_status: 0)
    #Can make the assumption that this is an assigment participant because assignment badge
    @submissions = pariticpant.team.submissions
  end

  def badge_params
    params.require(:badge).permit(:name, :description, :image_name)
  end

  def award


  end

  def credly_designer
    tokens = UserCredlyToken.where(user_id: current_user.id).last

    response = RestClient.post("https://credly.com/badge-builder/code",
                               {access_token: tokens.access_token},
                               headers = {"X-Api-Key":@@x_api_key, "X-Api-Secret": @@x_api_secret})
    results = JSON.parse(response.to_str)
    if results['temp_token']
      render :json => results
    else
      render status: 0, :json => {"message":"badge builder is currently unreachable"}
    end
  end

  def login_credly_submit
      if !params['credly']['username'].nil? && !params['credly']['password'].nil?
        begin
          response = RestClient::Request.execute method: :post,
                                                 url: "https://api.credly.com/v1.1/authenticate",
                                                 user: params['credly']['username'].strip,
                                                 password: params['credly']['password'].strip,
                                                 headers: {"X-Api-Key":@@x_api_key, "X-Api-Secret": @@x_api_secret}
          result = JSON.parse(response.to_str)

          if !result['data']['token'].nil?
            tokens = UserCredlyToken.new(user: current_user, access_token: result['data']['token'], refresh_token: result['data']['refresh_token'])
            tokens.save
            redirect_to action: 'new'
          end
        rescue StandardError => e
          flash[:error] = "I can't log in wih the provided credential, please try again or <a href='https://connect.credly.com/#!/sign-in/user'>reset your credly password here</a>"
          render action: 'login_credly'
        end
      end
  end

end
