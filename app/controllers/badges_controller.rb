# added the badges controller as part of E1822
# added a create method for badge creation functionality
class BadgesController < ApplicationController
  require 'json'
  require 'rest-client'

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

    image_icon = "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X57HPdxUAS0QONO5p/MddXfambFqpsV56uA1nuVQPM+tj5zkFQzAdB7g/phWNUVGOCM0PbBav45r06a6c7yuC7ZDCwbbeiu69gR3SofTW8ZoGZbPPlH4jGf5o5mbjJlLcgsG3FzLI9waw7FlkaPKSk7vDGW5WqjN9+QqJ3urlUOuw+7mrEAG3rhEKnW8yIucisOdHM0Y7uFj0yYejX4phDzdvna5m6AFXYnDXe38mpWpPKxoLlP5PlUW9XUk/grwHndZuyY69ZBZwrM0Jvzhmn0pHORhJia6ep2JjxJeojXhD9msS6OaJyhMek/S1mRxO29a1hccz+s0T7M0FWb9J55c/pLtdCf8kUd/NfJzVsWwh53AMOP5Gu/aUjRn+SXrnL78LDnpE42Z8/Gtvhr4JeujOBdUYBrj+ArbMGvpqXWXxileYI0QSzIwljv4A80JF8Vwl0IVT7LCCVMsnRPQZbGSL3MTBUk23ShIGa/yGlUoic6KGThHMAA+iriL25mXJPGHn095mXeoT86RZwGAi9k8yI4EezUqp/l3bnPKJoUXcZaFuViqPK7jDq5nWgI6xnopYxtvUUYg0RVhPs4UTB8+5nITW1kWtzn3Go18zBt8SINTGyEnC6avfONYya1sZLbFMYqfI7zNnymnJ9GFthKnC6YPDzNYz82sZIoFTVQvx9nFO+znPKYcJp7MpIZg+shgDiVsYTn5Jk1UClDDHt5lL2ecETSPTioJpo9s5rKGDVzNlKgbKZ0uatjH+3xKPaFEFymepJ5g+shkJsWs4RpmMcZAV1+YZo6xj485xFn7HjITPakqmD485DOfa7iGhUwhZwT/JkgLdRzmM0qpocOpMdDopLZgLpBGPjOZz3xmM5U8MvAgoxKki/PUUU0F1ZyiPVU8leERgrkUiTRyyCGLdFyE6KGTdrpSy0sRCAQCgUAgEAgEAoFAIBAIBAKBQCAQCAQCgUAgEAgEAsGQ/H8hHz/xwkcmCwAAACV0RVh0ZGF0ZTpjcmVhdGUAMjAxNy0xMS0wOFQwMjoxODozMSswMDowMETLY/YAAAAldEVYdGRhdGU6bW9kaWZ5ADIwMTctMTEtMDhUMDI6MTg6MzErMDA6MDA1lttKAAAAR3RFWHRzb2Z0d2FyZQBJbWFnZU1hZ2ljayA2LjcuNy0xMCAyMDE0LTAzLTA2IFExNiBodHRwOi8vd3d3LmltYWdlbWFnaWNrLm9yZ2+foqIAAAAYdEVYdFRodW1iOjpEb2N1bWVudDo6UGFnZXMAMaf/uy8AAAAYdEVYdFRodW1iOjpJbWFnZTo6aGVpZ2h0ADYwMDWDvmUAAAAXdEVYdFRodW1iOjpJbWFnZTo6V2lkdGgANjAw6S/t6AAAABl0RVh0VGh1bWI6Ok1pbWV0eXBlAGltYWdlL3BuZz+yVk4AAAARdEVYdFRodW1iOjpTaXplADE3S0JCRr5ovAAAABJ0RVh0VGh1bWI6OlVSSQBmaWxlOi8vwXeLzwAAAABJRU5ErkJggg=="
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

    # image_file = params[:badge][:image_file]
    # if !image_file.nil?
    #   File.open(Rails.root.join('app', 'assets', 'images', 'badges', image_file.original_filename), 'wb') do |file|
    #   file.write(image_file.read)
    # end
    # @badge.image_name = image_file.original_filename
    # else
    #   @badge.image_name = ''
    # end
    #
    # respond_to do |format|
    #   if @badge.save
    #     format.html { redirect_to session.delete(:return_to), notice: 'Badge was successfully created' }
    #   else
    #     format.html { render :new }
    #     format.json { render json: @badge.errors, status: :unprocessable_entity }
    #   end
    # end
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
