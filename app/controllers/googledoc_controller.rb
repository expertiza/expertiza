class GoogledocController < ApplicationController

  def action_allowed?
    ['Student',
     'Instructor',
     'Teaching Assistant'].include? current_user.role.name
  end
  require 'google/api_client'
  def initialize(user_email=nil)
    @client = Google::APIClient.new
    @drive = @client.discovered_api('drive', 'v3')
    key_file_name = 'client_key.p12'
    key = Google::APIClient::PKCS12.load_key("#{Rails.root.to_s}/config/#{key_file_name}", 'notasecret')

    asserter = Google::APIClient::JWTAsserter.new(
        'googledoc-1@expertiza-150802.iam.gserviceaccount.com',
        'https://www.googleapis.com/auth/drive',
        key)

    @client.authorization = asserter.authorize(user_email)
  end

  def insert_file(title, description, parent_id, mime_type, file_name)
    #file = @drive.files.insert.request_schema.new({
     #                                                 #'title' => title,
      #                                               #'description' => description,
       #                                               'mime_type' => mime_type
        #                                          })
    # Set the parent folder.
    if parent_id
      file.parents = [{'id' => parent_id}]
    end
    media = Google::APIClient::UploadIO.new(file_name, mime_type)
    result = @client.execute(
        :api_method => @drive.files.create,
        :body_object => file,
        :media => media,
        #:parameters => {
            #'uploadType' => 'multipart',
            #'convert' => true,
            #'alt' => 'json'}
            )
    #result = @client.execute(:api_method => @drive.files.create     )

    #file_metadata = {
     #   name: 'Project plan',
      #  mime_type: 'application/vnd.google-apps.drive-sdk'
    #}

    #result = @client.execute(:api_method => @drive.files.create)


    if result.status == 200
      #get_file(JSON.parse(result.response.body)["id"])
      render :text =>  "An error occurred: #{JSON.parse(result.response.body)}"
      return result.data
    else
      render :text =>  "An error occurred: #{result.data['error']['message']}"
      return nil
    end
  end

  def list_files
    result = @client.execute!(:api_method => @drive.files.list)
    result.data.to_hash
  end

  def get_file(file_id)
    result = @client.execute!(
        :api_method => @drive.files.get,
        :parameters => { 'fileId' => file_id })
    result.data.to_hash
    end
  private

  def token
    @client.authorization.access_token
  end
end