require 'rails_helper'

describe NotificationsController do
  it "#run_get_notification" do
    user = build(:student)
    stub_current_user(user, user.role.name, user.role)
    get "run_get_notification"
    expect(response).to redirect_to('/')
  end
end
