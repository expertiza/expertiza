json.array!(@feedback_settings) do |feedback_setting|
  json.extract! feedback_setting, :id, :support_mail, :max_attachments, :max_attachment_size, :wrong_retries, :wait_duration, :wait_duration_increment, :support_team
  json.url feedback_setting_url(feedback_setting, format: :json)
end
