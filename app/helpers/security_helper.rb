module SecurityHelper
  class SpecialCharsHandler
    def special_chars
      special = "/\\?<>|&$#"
    end

    def contains_special_chars?(str)
      special = special_chars
      regex = /[#{special.gsub(/./){|char| "\\#{char}"}}]/

      return !(str =~ regex).nil?
    end

    def check_for_special_char(str)
      if contains_special_chars? str
        flash[:error] = "This page doesn't allow input that contains " + special_chars
      end
    end

    def json_valid?(str)
      begin
        JSON.parse(str)
        return true
      rescue JSON::ParserError, TypeError => e
        return false
      end
    end

    def date_valid?(date)
      begin
        Date.parse(date)
        return true
      rescue ArgumentError
        return false
      end
    end
  end
end