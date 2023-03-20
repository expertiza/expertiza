module UserHelper
  # User Helper Module
  def yesorno(elt)
    if [true,false].include? elt
      elt ? 'yes' : 'no'
    else
      ''
    end
  end
end
