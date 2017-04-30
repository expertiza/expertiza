class HttpRequestTestHelper
  def self.setup_mock(response_status,content)
    if response_stats.is_a? Net::HTTPSuccess
        class Net::HTTPSuccess 
            define_method(:body) {
                return content        
            }
        end
    elsif  response_stats.is_a? Net::HTTPError
        class Net::HTTPError 
            define_method(:body) {
                return content        
            }
        end
    end
    class << HttpRequest
      define_method(method){ |url| 
        resp = response_status.new(1.0, 200, "OK")
        return  resp
      }
    end
  end
end
