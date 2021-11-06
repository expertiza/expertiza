module QuestionAnalytic
  def unique_character_count
    self.txt.gsub(/\s+/, "").downcase.split(//).uniq.length
  end

  def character_count
    self.txt.bytesize
  end

  def word_count
    self.txt.gsub(/[^0-9A-Za-z]/, ' ').split(' ').count
  end
end
