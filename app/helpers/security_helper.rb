module SecurityHelper
  def special_chars
    special = "/\\?<>|&$#"
  end

  def contains_special_chars?(str)
    special = special_chars
    regex = /[#{special.gsub(/./) {|char| "\\#{char}" }}]/

    !(str =~ regex).nil?
  end

  def warn_for_special_chars(str, field_name)
    if contains_special_chars? str
      flash[:error] = field_name + " must not contain special characters '" + special_chars + "'."
      return true
    end
    false
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
