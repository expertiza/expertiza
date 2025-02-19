module StringOperationHelper
  def string_similarity(str1, str2)
    # Perform bigram comparison between two strings and return a percentage match in decimal form
    pairs1 = get_ngrams(str1, 3)
    pairs2 = get_ngrams(str2, 3)

    (2.0 * (pairs1 & pairs2).size / (pairs1.size + pairs2.size))
  end

  private

  def get_ngrams(string, n)
    # Takes a string and returns a list of ngrams
    s = string.downcase
    bg = []
    s.split('').each_with_index do |_item, index|
      bg << s[index..index + n]
    end
    bg
  end
end
