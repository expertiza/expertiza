
class GoogleDocFetcher
  require 'http_request'

  class << self
    def SupportsUrl?(url)
      lowerCaseUrl = url.downcase
      ((lowerCaseUrl.include? "drive.google.com") or
       (lowerCaseUrl.include? "docs.google.com"))
    end
  end

  def initialize(params)
    @url = params["url"]
  end

  def FetchContent
    fileId = getIdFromUrl(@url)
    if fileId.length >= 0
      # TODO: requires that permissions on the doc are public, or anyone with the link can view, maybe write a validate function
      reqUrl = "https://www.googleapis.com/drive/v3/files/#{fileId}" + "/export?" + "mimeType=text/plain" + "&key=AIzaSyCL29lEEYdaWj-M6_cQRpUeNIJFN_gTrP4"

      puts "Fetching Google Doc ID: #{fileId}"
      res = HttpRequest.Get(reqUrl)

      if res.is_a? Net::HTTPSuccess
        res.body
      else
        puts "Failed request to Google Doc URL: #{@url}, code #{res.code}"
        ""
      end

    else
      puts "Couldn't parse Google Docs URL: " + @url
      ""
    end
  end

  private
  def getIdFromUrl(url)
    idRegex = /[a-zA-Z0-9\-\_\+\.\~]+/
    idQueryRegex = /id=(#{idRegex})[\/&]?/
    idPathRegex = /\/d\/(#{idRegex})\//

    idQueryRegex.match(url) {|m|
      puts "Found ID as " + m.captures[0] + " in query: " + url
      return m.captures[0]
    }

    idPathRegex.match(url) {|m|
      puts "Found ID as " + m.captures[0] + " in path: " + url
      return m.captures[0]
    }

    puts "ID not found in: " + url
    return ""
  end

end
