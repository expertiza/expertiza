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

  def self.parse_response(parsed_response, response, list_badges = Array.new)
    user_data = nil

    if response.code == '200' && !parsed_response['data'].nil?
      parsed_response['data'].each do |badge|
        if Badge.where('credly_badge_id = ?', badge['id']).blank?
          new_badge = Badge.new
          new_badge.name = badge['title']
          new_badge.credly_badge_id = badge['id']
          new_badge.save!
        end
        badge_info = Hash.new
        badge_info['badge_image_url'] = badge['image_url']
        badge_info['badge_title'] = badge['title']
        badge = Badge.where('credly_badge_id = ?', badge['id']).first
        badge_info['badge_id'] = badge.id
        list_badges.push badge_info
      end
    else
      user_data = parsed_response['meta']
    end
    return list_badges, user_data
  end

  def self.award_badge_user(user_id, student_credly_id, badge_id)
    uri = URI.parse(CREDLY_API_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    token = User.select('credly_id, credly_accesstoken').where('id = ?', user_id)
    request = Net::HTTP::Post.new('/v1.1/member_badges?access_token=' + token[0].credly_accesstoken)
    request['X-Api-Key'] = CREDLY_API_TOKEN
    request['X-Api-Secret'] = CREDLY_API_SECRET
    request.set_form_data({'member_id' => student_credly_id, 'badge_id' => badge_id})
    response = http.request(request)
    parsed_response = JSON.parse(response.body)

    if response.code == '200' && !parsed_response['data'].nil?
      user_data = parsed_response['meta']
      if user_data['status'] == 'OK'
        trust_instructor(student_credly_id, token[0].credly_id.to_s)
      end
    else
      user_data = parsed_response['meta']
    end
  end

  def self.check_instructor_trust(student_credly_id, instructor_credly_id)
    uri = URI.parse(CREDLY_API_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    token = User.select('credly_accesstoken').where('credly_id = ?', student_credly_id)
    request = Net::HTTP::Get.new('/v1.1/me/trusted/'+ instructor_credly_id + '?access_token=' + token[0].credly_accesstoken)
    request['X-Api-Key'] = CREDLY_API_TOKEN
    request['X-Api-Secret'] = CREDLY_API_SECRET
    response = http.request(request)
    parsed_response = JSON.parse(response.body)
    if response.code == '200'
      data = parsed_response['data']
      if !data.nil?
        data
      else
        true
      end
    else
      user_data = parsed_response['meta']
      false
    end
  end

  def self.trust_instructor(student_credly_id, instructor_credly_id)
    unless check_instructor_trust(student_credly_id, instructor_credly_id)
      uri = URI.parse(CREDLY_API_URL)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      token = User.select('credly_accesstoken').where('credly_id = ?', student_credly_id)
      request = Net::HTTP::Put.new('/v1.1/me/trusted/'+ instructor_credly_id + '?access_token=' + token[0].credly_accesstoken)
      request['X-Api-Key'] = CREDLY_API_TOKEN
      request['X-Api-Secret'] = CREDLY_API_SECRET
      response = http.request(request)
      # parsed_response = JSON.parse(response.body)

      if response.code == '200'
        data = response.body
      else
        user_data = response.body
      end
    end
  end

end