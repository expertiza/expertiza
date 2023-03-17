module UserHelper
  def yesorno(elt)
    if elt == true
      'yes'
    elsif elt == false
      'no'
    else
      ''
    end
  end
end