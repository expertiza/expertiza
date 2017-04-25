class SimiCheckWebService
  require 'rest-client'

  @@api_key = '34fdeffbe203432383df873a0306b005595ff4c6f040447a9ec52cf7bee0af2a4b6ef22fdb414fe09dba556a50085505388f8b837afc4364b226d058a2dc84bc'
  @@base_uri = 'https://www.simicheck.com/api'

  ############################################
  # Comparison Operations
  ############################################

  # Lists all comparisons for the SimiCheck account
  # Parameters:
  #   <none>
  # Returns:
  #   response = RestClient::Response
  def self.get_all_comparisons
    full_url = @@base_uri + '/comparisons'
    response = RestClient::Request.execute(method: :get,
                                           url: full_url,
                                           headers: {simicheck_api_key: @@api_key},
                                           verify_ssl: false)
    return response
  end

  # Creates a new comparison
  # Parameters:
  #   comparison_name (optional) - string containing the name for the new comparison
  #                                (name will be date and time if not provided)
  # Returns:
  #   response = RestClient::Response
  def self.new_comparison(comparison_name = '')
    full_url = @@base_uri + '/comparison'
    json_body = {:comparison_name => comparison_name}.to_json
    response = RestClient::Request.execute(method: :put,
                                           url: full_url,
                                           payload: json_body,
                                           headers:
                                               {
                                                   simicheck_api_key: @@api_key,
                                                   content_type: :json,
                                                   accept: :json
                                               },
                                           verify_ssl: false)
    return response
  end

  # Deletes a comparison
  # Parameters:
  #   comparison_id - string id of the comparison to delete
  # Returns:
  #   response = RestClient::Response (NO BODY)
  def self.delete_comparison(comparison_id)
    full_url = @@base_uri + '/comparison/' + comparison_id
    response = RestClient::Request.execute(method: :delete,
                                           url: full_url,
                                           headers: {simicheck_api_key: @@api_key},
                                           verify_ssl: false)
    return response
  end

  # Gets the details about a comparison
  # Parameters:
  #   comparison_id - string id of the comparison to look up
  # Returns:
  #   response = RestClient::Response
  def self.get_comparison_details(comparison_id)
    full_url = @@base_uri + '/comparison/' + comparison_id
    response = RestClient::Request.execute(method: :get,
                                           url: full_url,
                                           headers: {simicheck_api_key: @@api_key},
                                           verify_ssl: false)
    return response
  end

  # Updates a comparison (currently only the name)
  # Parameters:
  #   comparison_id - string id of the comparison to update
  #   new_comparison_name - string containing the new name for the comparison
  # Returns:
  #   response = RestClient::Response (NO BODY)
  def self.update_comparison(comparison_id, new_comparison_name)
    full_url = @@base_uri + '/comparison/' + comparison_id
    json_body = {:comparison_name => new_comparison_name}.to_json
    response = RestClient::Request.execute(method: :post,
                                           url: full_url,
                                           payload: json_body,
                                           headers:
                                               {
                                                   simicheck_api_key: @@api_key,
                                                   content_type: :json,
                                                   accept: :json
                                               },
                                           verify_ssl: false)
    return response
  end

  ############################################
  # File Operations
  ############################################

  # Uploads a file
  # Parameters:
  #   comparison_id - string id of the comparison to update
  #   path_to_file - string containing the path to the file being uploaded
  # Returns:
  #   response = RestClient::Response
  def self.upload_file(comparison_id, path_to_file)
    full_url = @@base_uri + '/upload_file/' + comparison_id
    file_to_upload = File.new(path_to_file, 'rb')
    json_body = {"file" => file_to_upload} # don't use .to_json!
    response = RestClient::Request.execute(method: :put,
                                           url: full_url,
                                           payload: json_body,
                                           headers:
                                               {
                                                   simicheck_api_key: @@api_key,
                                                   content_type: 'multipart/form-data',
                                                   accept: :json
                                               },
                                           verify_ssl: false)
    return response
  end

  # Deletes files from a comparison
  # Parameters:
  #   comparison_id - string id of the comparison to update
  #   filenames_to_delete - array of strings containing filenames to be deleted
  # Returns:
  #   response = RestClient::Response (NO BODY)
  def self.delete_files(comparison_id, filenames_to_delete)
    full_url = @@base_uri + '/delete_files/' + comparison_id
    json_body = {"filenames" => filenames_to_delete}.to_json
    response = RestClient::Request.execute(method: :post,
                                           url: full_url,
                                           payload: json_body,
                                           headers:
                                               {
                                                   simicheck_api_key: @@api_key,
                                                   content_type: :json,
                                                   accept: :json
                                               },
                                           verify_ssl: false)
    return response
  end

  ############################################
  # Similarity
  ############################################

  # Gets the results of the similarity comparison
  # Parameters:
  #   comparison_id - string id of the comparison to update
  # Returns:
  #   response = RestClient::Response
  def self.get_similarity_nxn(comparison_id)
    full_url = @@base_uri + '/similarity_nxn/' + comparison_id
    response = RestClient::Request.execute(method: :get,
                                           url: full_url,
                                           headers: {simicheck_api_key: @@api_key},
                                           verify_ssl: false)
    return response
  end

  # Starts the computation of file similarity for a comparison
  # Parameters:
  #   comparison_id - string id of the comparison to update
  # Returns:
  #   response = RestClient::Response
  def self.post_similarity_nxn(comparison_id, callback_url = '')
    full_url = @@base_uri + '/similarity_nxn/' + comparison_id
    if callback_url.empty?
      json_body = {}.to_json
    else
      json_body = {"callback_url" => callback_url}.to_json
    end
    response = RestClient::Request.execute(method: :post,
                                           url: full_url,
                                           payload: json_body,
                                           headers:
                                               {
                                                   simicheck_api_key: @@api_key,
                                                   content_type: :json,
                                                   accept: :json
                                               },
                                           verify_ssl: false)
    return response
  end

  # # Checks where a NxN comparison has terminated - NOT WORKING?
  # def self.get_similarity_status(comparison_id)
  #   full_url = @@base_uri + '/similarity_status/' + comparison_id
  #   puts full_url
  #   response = RestClient::Request.execute(method: :get,
  #                                          url: full_url,
  #                                          headers:
  #                                              {
  #                                                  simicheck_api_key: @@api_key,
  #                                                  accept: :json
  #                                              },
  #                                          verify_ssl: false)
  #   return response
  # end

  # Gets the latest results for the similarity of one file wrt. all other files in a comparison
  def self.get_similarity_1xn(comparison_id, filename)
    full_url = @@base_uri + '/similarity_1xn/' + comparison_id
    json_body = {"filename" => filename}.to_json
    response = RestClient::Request.execute(method: :get,
                                           url: full_url,
                                           payload: json_body,
                                           headers:
                                               {
                                                   simicheck_api_key: @@api_key,
                                                   content_type: :json,
                                                   accept: :json
                                               },
                                           verify_ssl: false)
    return response
  end

  # Finds the files in a comparison that are most similar to a given file
  def self.post_similarity_1xn(comparison_id, filename, callback_url = '')
    full_url = @@base_uri + '/similarity_1xn/' + comparison_id
    if callback_url.empty?
      json_body = {"filename" => filename}.to_json
    else
      json_body = {"filename" => filename, "callback_url" => callback_url}.to_json
    end
    response = RestClient::Request.execute(method: :post,
                                           url: full_url,
                                           payload: json_body,
                                           headers:
                                               {
                                                   simicheck_api_key: @@api_key,
                                                   content_type: :json,
                                                   accept: :json
                                               },
                                           verify_ssl: false)
    return response
  end

  ############################################
  # Visualization
  ############################################

  # Gets the results of the similarity comparison
  def self.visualize_similarity(comparison_id)
    full_url = @@base_uri + '/visualize_similarity/' + comparison_id
    response = RestClient::Request.execute(method: :get,
                                           url: full_url,
                                           headers: {simicheck_api_key: @@api_key},
                                           verify_ssl: false)
    return response
  end

  # Gets the results of similarity comparison
  def self.visualize_comparison(comparison_id, file_id_1, file_id_2)
    full_url = @@base_uri + '/visualize_comparison/' + comparison_id + '/' + file_id_1 + '/' + file_id_2
    response = RestClient::Request.execute(method: :get,
                                           url: full_url,
                                           headers: {simicheck_api_key: @@api_key},
                                           verify_ssl: false)
    return response
  end
end


###
# TESTING
###

# Create new comparison
response = SimiCheckWebService.new_comparison('test new comparison')
puts response.code
json_response = JSON.parse(response.body)
new_id = json_response["id"]
puts new_id
puts '----'
# Get list of all comparisons
response = SimiCheckWebService.get_all_comparisons
puts response.code
json_response = JSON.parse(response.body)
json_response["comparisons"].each do |comparison|
  puts comparison["comparison_name"] + ' (' + comparison["id"] + ')'
end
puts '----'

# Upload a file to the new comparison
response = SimiCheckWebService.upload_file(new_id, '/tmp/helloworld.txt')
puts response.code
json_response = JSON.parse(response.body)
helloworld_id = json_response["id"]
puts json_response["name"] + ' (' + json_response["id"] + ')'
puts '----'
# Upload another file to the new comparison
response = SimiCheckWebService.upload_file(new_id, '/tmp/helloworld2.txt')
puts response.code
json_response = JSON.parse(response.body)
puts json_response["name"] + ' (' + json_response["id"] + ')'
puts '----'
# Upload another file to the new comparison
response = SimiCheckWebService.upload_file(new_id, '/tmp/not_helloworld.txt')
puts response.code
json_response = JSON.parse(response.body)
not_helloworld_id = json_response["id"]
puts json_response["name"] + ' (' + json_response["id"] + ')'
puts '----'

# Change the new comparison name
response = SimiCheckWebService.update_comparison(new_id, 'test update comparison')
puts response.code
puts '----'

# Look up the details for the newly created comparison
response = SimiCheckWebService.get_comparison_details(new_id)
puts response.code
json_response = JSON.parse(response.body)
puts json_response["name"] + ':'
json_response["files"].each do |file|
  puts file["name"] + ' (' + file["id"].to_s + ')'
end
puts '----'

# Start the nxn comparison
response = SimiCheckWebService.post_similarity_nxn(new_id)
puts response.code
puts '----'
# Get the top similarities among the files submitted
# (Wait until it completes)
while true
  begin
    response = SimiCheckWebService.get_similarity_nxn(new_id)
    if response.code == 200
      break
    end
  rescue
    puts 'Waiting 30 seconds to check again...'
    sleep(30)
    next
  end
end
json_response = JSON.parse(response.body)
json_response["similarities"].each do |similarity|
  puts similarity["fn1"] + ' & ' + similarity["fn2"] + ' are ' + similarity["similarity"].to_s + '% alike'
end
puts '----'

# Visualize similarity (all files)
response = SimiCheckWebService.visualize_similarity(new_id)
puts response.code
puts response.body
puts '----'
# Visualize comparison (2 files)
response = SimiCheckWebService.visualize_comparison(new_id, helloworld_id, not_helloworld_id)
puts response.code
puts response.body
puts '----'

# Delete a file from the new comparison
response = SimiCheckWebService.delete_files(new_id, ["helloworld.txt"])
puts response.code
puts '----'
# Look up the details for the newly created comparison
response = SimiCheckWebService.get_comparison_details(new_id)
response.code
json_response = JSON.parse(response.body)
puts json_response["name"] + ':'
json_response["files"].each do |file|
  puts file["name"] + ' (' + file["id"].to_s + ')'
end
puts '----'
# Delete the newly created comparison
response = SimiCheckWebService.delete_comparison(new_id)
puts response.code
puts '----'
# Get list of all comparisons
response = SimiCheckWebService.get_all_comparisons
puts response.code
json_response = JSON.parse(response.body)
json_response["comparisons"].each do |comparison|
  puts comparison["comparison_name"] + ' (' + comparison["id"] + ')'
end
puts '----'