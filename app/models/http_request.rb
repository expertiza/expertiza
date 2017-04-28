
class HttpRequest
  require 'net/http'
  
  class << self

    # http://ruby-doc.org/stdlib-2.4.1/libdoc/net/http/rdoc/Net/HTTP.html
    def Get(url, limit = 5)
      if limit <= 0
        puts "Too many redirects, last URL: #{url}"
        ""
      end

      uri = URI.parse(url)
      req = Net::HTTP::Get.new(uri.to_s)
      res = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') { |http|
        http.request(req)
      }

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
        puts "Http get redirected to: " + new_uri.to_s
        self.Get(new_uri.to_s, limit - 1)

      else
        puts "Unhandled Http request status: #{res.code}"
        ""
      end
    end

    def GetFile(url, filename)
      res = self.Get(url)

      # http://stackoverflow.com/questions/2571547/rails-how-to-to-download-a-file-from-a-http-and-save-it-into-database
      if res.is_a? Net::HTTPSuccess
        # Note from docs (https://apidock.com/ruby/Tempfile)
        # When a Tempfile object is garbage collected, or when the Ruby interpreter exits, 
        # its associated temporary file is automatically deleted.
        tempfile = Tempfile.new(filename)
        File.open(tempfile.path, 'wb') { |f|
          f.write res.body
        }

        # It is assumed that this file will be deleted externally
        tempfile
      else
        puts "Failed to get file at URL: #{@url}, code #{res.code}"
        false
      end
    end

    # Don't allow this object to be instantiated
    private :new
  end
end
