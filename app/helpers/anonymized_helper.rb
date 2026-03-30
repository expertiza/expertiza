# AnonymizedHelper
module AnonymizedHelper
  def anonymized_view?(ip_address = nil)
    anonymized_view_starter_ips =
      $redis.get('anonymized_view_starter_ips') || ''
    return true if ip_address &&
      anonymized_view_starter_ips.include?(ip_address)

    false
  end

  # E1991 : This function returns original name of the user
  # from their anonymized names. The process of obtaining
  # real name is exactly opposite of what we'd do to get
  # anonymized name from their real name.
  def real_user_from_anonymized_name(anonymized_name)
    user = User.find_by(name: anonymized_name)
    user
  end
end
