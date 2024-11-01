module ScoreAnalytic
  def unique_character_count
    comments.gsub(/[^0-9A-Za-z ]/, '').downcase.split(' ').uniq.count
  end

  def character_count
    comments.bytesize
  end

  def word_count
    comments.gsub(/[^0-9A-Za-z]/, ' ').split(' ').count
  end
end
