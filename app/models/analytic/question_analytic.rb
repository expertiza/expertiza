module QuestionAnalytic
  def unique_character_count
    txt.gsub(/\s+/, '').downcase.split(//).uniq.length
  end

  def character_count
    txt.bytesize
  end

  def word_count
    txt.gsub(/[^0-9A-Za-z]/, ' ').split(' ').count
  end
end
