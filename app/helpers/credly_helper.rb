module CredlyHelper

  CREDLY_API_URL = 'https://api.credly.com'
  CREDLY_API_TOKEN = 'f14c0138c043c3159420f297276eab61'
  CREDLY_API_SECRET = '6qmzTxOQZJfF5K1ExH80K+umX9gfU5lmtswycO9TycswGbKEIPwuoXxcIohF4d6go0FeLMRv9uV+MD0jmeQsHBDaTNKa+blumqcd+cfK1y5lqTbLiLZsxdue9vth3Lh9U6Juy1rvy2VGYo8EOqh46PMjOmmOTUIZan9vvaf8Z0I='

  def self.get_badges_created(user_id)
    uri = URI.parse(CREDLY_API_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    token = User.select('credly_accesstoken').where('id = ?', user_id)
    request = Net::HTTP::Get.new('/v1.1/me/badges/created?order_direction=ASC&access_token=' + token[0].credly_accesstoken)
    request['X-Api-Key'] = CREDLY_API_TOKEN
    request['X-Api-Secret'] = CREDLY_API_SECRET
    response = http.request(request)
    response
  end

  def self.parse_response(parsed_response, response)
    list_badges = Array.new
    user_data = nil

    if response.code == '200' && !parsed_response['data'].nil?
      parsed_response['data'].each do |badge|
        badge_info = Hash.new
        badge_info['badge_image_url'] = badge['image_url']
        badge_info['badge_title'] = badge['title']
        badge_info['badge_id'] = badge['id']
        if Badge.where('credly_badge_id = ?', badge['id']).blank?
          new_badge = Badge.new
          new_badge.name = badge['title']
          new_badge.credly_badge_id = badge['id']
          new_badge.save!
        end
        list_badges.push badge_info
      end
    else
      user_data = parsed_response['meta']
    end
    return list_badges, user_data
  end

end