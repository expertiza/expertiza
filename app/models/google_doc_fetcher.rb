class GoogleDocFetcher
  require 'http_request'

  class << self
    def supports_url?(url)
      lower_case_url = url.downcase
      allowed_hosts = ["drive.google.com", "docs.google.com"]
      allowed_hosts.each do |allowed_host|
        if (HttpRequest.valid_url?(url) && lower_case_url.include?(allowed_host))
          return true
        end
      end
      return false
    end
  end

  def initialize(params)
    @url = params['url']
  end

  def fetch_content
    file_id = get_id_from_url(@url)
    if file_id.length >= 0
      req_url = "https://www.googleapis.com/drive/v3/files/#{file_id}" \
                + '/export?' + 'mimeType=text/plain' \
                + '&key=' + PLAGIARISM_CHECKER_CONFIG['google_docs_key']

      res = HttpRequest.get(req_url)

      if res.is_a? Net::HTTPSuccess
        res.body
      else
        ''
      end
    else
      ''
    end
  end

  private

  def get_id_from_url(url)
    id_regex = /[a-zA-Z0-9\-\_\+\.\~]+/
    id_query_regex = %r{id=(#{id_regex})[/&]?}
    id_path_regex = %r{/d/(#{id_regex})/}

    id_query_regex.match(url) do |m|
      return m.captures[0]
    end

    id_path_regex.match(url) do |m|
      return m.captures[0]
    end

    ''
  end
end
