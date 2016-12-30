class SimicheckComparison < ActiveRecord::Base
  belongs_to :assignment
  validates :file_type, :presence => true
  validates :assignment_id, :presence =>true
  validates :comparison_key, :presence => true
  #simicheck account - expertiza@ncsu.edu password - expertiza123

  def self.create_simicheck_comparison(assignment_id,fileType)
    url = "http://simicheck.com/api/comparison"
    key = "0a6a26fd61c943718a623b62fc457e1a3e110abe11df4535bb037478e04a9b6af60d8b9fb2e04356b5dda2594150e44642fad227b8e749c89359836c4420edd5"
    payload = ""
    response = RestClient.put(url, payload, {:simicheck_api_key=>key})
    if(response.code == 200)
      response_hash = JSON.parse(response.body)
      comparison_key = response_hash['id']
      comparison = SimicheckComparison.create({ :assignment_id => assignment_id, :comparison_key => comparison_key, :file_type => fileType })
      return comparison
    end
    return nil
  end

  def send_file_to_simicheck(file)
    url = "http://simicheck.com/api/files/" + self.comparison_key
    key = "0a6a26fd61c943718a623b62fc457e1a3e110abe11df4535bb037478e04a9b6af60d8b9fb2e04356b5dda2594150e44642fad227b8e749c89359836c4420edd5"
    payload = {:file => file}
    response = RestClient.put(url, payload, {:simicheck_api_key=>key})
    if(response.code == 200)
      return true
    end
    return false
  end

  def get_visualisation_url
    url = "http://simicheck.com/api/visualize_similarity/"
    key = "0a6a26fd61c943718a623b62fc457e1a3e110abe11df4535bb037478e04a9b6af60d8b9fb2e04356b5dda2594150e44642fad227b8e749c89359836c4420edd5"
    response = RestClient.get(url + self.comparison_key, {:simicheck_api_key=>key})
    file_type = self.file_type
    if(self.file_type == "file")
      file_type = "Uploaded Files"
    end
    if(self.file_type == "html")
      file_type = "Uploaded Web Pages"
    end
    visualisation_url = nil
    if(response.code == 200)
      visualisation_url = response.body
    end
    return [file_type, "http://www.simicheck.com" + visualisation_url]
  end

  def get_status
    url = "http://simicheck.com/api/similarity_status/"
    key = "0a6a26fd61c943718a623b62fc457e1a3e110abe11df4535bb037478e04a9b6af60d8b9fb2e04356b5dda2594150e44642fad227b8e749c89359836c4420edd5"
    url += self.comparison_key
    response = RestClient.get(url, {:simicheck_api_key=>key})
    status = false
    if(response.code == 200)
      status = JSON.parse(response.body)['ready']
    end
    return status
  end
end