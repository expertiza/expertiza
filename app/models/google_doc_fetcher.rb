
class GoogleDocFetcher
  require 'http_request'

  class << self
    def supports_url?(url)
      lowerCaseUrl = url.downcase
      (HttpRequest.is_valid_url(url) and
       ((lowerCaseUrl.include? "drive.google.com") or (lowerCaseUrl.include? "docs.google.com")))
    end
  end

  def initialize(params)
    @url = params["url"]
  end

  def fetch_content
    file_id = get_id_from_url(@url)
    if file_id.length >= 0
      # TODO: requires that permissions on the doc are public, or anyone with the link can view, maybe write a validate function
      # TODO: need to move API key elsewhere
      req_url = "https://www.googleapis.com/drive/v3/files/#{file_id}" + "/export?" + "mimeType=text/plain" + "&key=" + PLAGIARISM_CHECKER_CONFIG['google_docs_key']

      res = HttpRequest.get(req_url)

      if res.is_a? Net::HTTPSuccess
        res.body
      else
        ""
      end
    else
      ""
    end
  end

  private
  def get_id_from_url(url)
    id_regex = /[a-zA-Z0-9\-\_\+\.\~]+/
    id_query_regex = /id=(#{id_regex})[\/&]?/
    id_path_regex = /\/d\/(#{id_regex})\//

    id_query_regex.match(url) {|m|
      return m.captures[0]
    }

    id_path_regex.match(url) {|m|
      return m.captures[0]
    }

    ""
  end
end
