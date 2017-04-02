require 'rails_helper'

describe NotificationsController do
  it "#run_get_notification" do
    user = build(:student)
    stub_current_user(user, user.role.name, user.role)
    get "run_get_notification"
    expect(response).to redirect_to('/')
  end
  it "#run_create_notification" do
    user = build(:student)
    stub_current_user(user, user.role.name, user.role)
    get "run_create_notification"
    expect(response).to redirect_to('/')
  end

  it "#run_update_notification" do
    user = build(:student)
    stub_current_user(user, user.role.name, user.role)
    get "run_update_notification"
    expect(response).to redirect_to('/')
  end

  it "#run_destroy_notification" do
    user = build(:student)
    stub_current_user(user, user.role.name, user.role)
    get "run_destroy_notification"
    expect(response).to redirect_to('/')
  end
end
