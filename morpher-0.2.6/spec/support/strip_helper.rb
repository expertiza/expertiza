module StripHelper
  def strip(text)
    return text if text.empty?
    lines = text.lines
    match = /\A[ ]*/.match(lines.first)
    range = match[0].length..-1
    source = lines.map do |line|
      line[range]
    end.join
    source.chomp << "\n"
  end
end
