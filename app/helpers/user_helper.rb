module UserHelper
  def yesorno(elt)
    return ([true,false].include? elt) ? ( elt ? 'yes' : 'no')  : ''
  end
end