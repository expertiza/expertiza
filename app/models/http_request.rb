class HttpRequest
  require 'net/http'

  class << self
    # IP addresses and local URLs will not match, must include http(s)
    def valid_url?(url)
      /^#{URI::DEFAULT_PARSER.make_regexp}$/.match(url)
    end

    def get(url, limit = 5)
      return '' if limit <= 0

      uri = URI.parse(url)
      req = Net::HTTP::Get.new(uri.to_s)
      res = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.request(req)
      end

      case res
      when Net::HTTPSuccess then
        res

      when Net::HTTPRedirection then
        # http://stackoverflow.com/questions/6934185/ruby-net-http-following-redirects
        new_uri = URI.parse(res['Location'])
        if new_uri.relative?
          new_uri.scheme = uri.scheme
          new_uri.host = uri.host
        end
        get(new_uri.to_s, limit - 1)

      else
        ''
      end
    end

    # Don't allow this object to be instantiated
    private :new
  end
end
