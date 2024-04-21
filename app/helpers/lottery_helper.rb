module LotteryHelper
  def background_color_by_percentage(percentage)
    case percentage
    when 0...33
      'background-color: #ffcccc;' # Light red for low percentages
    when 33...66
      'background-color: #ffcc99;' # Light orange for medium percentages
    when 66..100
      'background-color: #ccffcc;' # Light green for high percentages
    else
      'background-color: none;' # No background if outside range
    end
  end
end
