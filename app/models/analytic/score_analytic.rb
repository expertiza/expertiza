module ScoreAnalytic
  def unique_character_count
    self.comments.gsub(/[^0-9A-Za-z ]/, '').downcase.split(" ").uniq.count
  end

  def character_count
    self.comments.bytesize
  end

  def word_count
    self.comments.gsub(/[^0-9A-Za-z]/, ' ').split(' ').count
  end
end
