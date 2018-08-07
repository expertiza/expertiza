# added the badges controller as part of E1822
# added a create method for badge creation functionality
class BadgesController < ApplicationController
  require 'json'
  require 'rest-client'
  require 'base64'
  require 'open-uri'

  @@access_token = "85d2e67ea0956aa7825e98ed9037f6c4627b593d28e537a9a7f1804b038b30dbf4b0544a68182f3d384e8aefb07e441a4abcac3100fb122b75491d1b816daa6e"

  def action_allowed?
    ['Instructor',
     'Teaching Assistant',
     'Administrator',
     'Super-Administrator'].include? current_role_name
  end

  def new

  end

  def redirect_to_assignment
    redirect_to session.delete(:return_to)
  end

  def create
    Thread.new do
      image_icon = Base64.encode64(open(params['image-icon']){ |f| f.read })
      form_data = { :title => params['badge']['name'],
                    :attachment => image_icon,
                    :short_description => params['badge']['description'],
                    :criteria => params['badge']['award_criteria'],
                    :is_giveable => true,
                    :is_claimable => false,
                    :expires_in => 60,
                    :multipart => true}
      headers = {"X-Api-Key":"ce56ea802fdee803531c310e30b0e32c",
                 "X-Api-Secret": "fXYe3lH8xN62mvj5K8AuCmw2Ca7SQcIekvftil1aVFhKQcQuMLmjqqC6/hr1x4SlV9TfHSQxWdvZ+K0bUnCxmBXLYMrGSnigU22fy26thaH6u6duNoZX/4qx+y9iLYa/jotMe5X1GNom+230nw2hLqPH0EiIotZ0t+5TUWl5cvU="}
      url = "https://api.credly.com/v1.1/badges?access_token=" + @@access_token
      response = RestClient.post(url, form_data, headers=headers)

      results = JSON.parse(response.to_str)
      render :json => results
    end
    redirect_to :action => 'new'
  end

  def icon_upload
    if params['fileupload'].content_type.include? "image"
      name = params['fileupload'].original_filename
      user_id = params['uid']
      directory = Rails.root.join('app', 'assets', 'images', 'badges', user_id)
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
    file_url = request.protocol + request.host_with_port + "/assets/badges/" + user_id + "/" + name
    render status: 200, json: {status: 200, message: "file uploaded", fileurl: file_url, filename: name}.to_json
  end

  def icons
    user_id = params['uid']
    directory = Rails.root.join('app', 'assets', 'images', 'badges', user_id)
    image_icons = Dir.entries(directory).reject {|f| File.directory?(f) || f[0].include?('.')}
    render status: 200, json: image_icons.map{|f| request.protocol + request.host_with_port + "/assets/badges/" + user_id + "/" + f}
  end

  def badge_params
    params.require(:badge).permit(:name, :description, :image_name)
  end

  def award
    @assignment = Assignment.find_by_id(params[:id])
    if @assignment
      @participants = @assignment.participants
      @questionaires = AssignmentQuestionnaire.where(assignment_id: @assignment.id)

    end

  end

  def credly_designer
    response = RestClient.post("https://credly.com/badge-builder/code", {
        access_token: @@access_token},
           headers={
               "X-Api-Key": "36da6f26bae6b3247e915245e518fec9",
               "X-Api-Secret": "FnRynfSWMybtY6nGzUEX1sCLfG6/UrDty1sHmnCCikJECbzSn+1jzOIzaE+IQqcigiXJ4s6ajBJunaVlId6vZVZ8eaF81S2muUUC7Iwu+knRYq6VSmkZzn/n13KL7ggXbqq7kw2ScfHfw/ZETM/CF6Z1snHD8kJ7LbvX07S/zxQ="})
    results = JSON.parse(response.to_str)
    if results['temp_token']
      render :json => results
    end
  end
end
