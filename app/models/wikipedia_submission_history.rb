class WikipediaSubmissionHistory < LinkSubmissionHistory
  def self.create(link, team, action)
    history_obj = WikipediaSubmissionHistory.new
    history_obj.submitted_detail = link
    history_obj.team = team
    history_obj.action = action
    return history_obj
  end

  def get_submitted_at_time(link)
    uri = URI(link)
    wiki_title = uri.path
    wiki_title.slice! "/index.php/"
    url = URI.parse('http://wiki.expertiza.ncsu.edu/api.php?action=query&prop=info&titles='+ wiki_title +'&format=json')
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }
    hash= JSON.parse res.body
    id = hash["query"]["pages"].keys
    return hash["query"]["pages"][id[0]]["touched"]
  end
end
