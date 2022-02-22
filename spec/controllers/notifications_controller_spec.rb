describe NotificationsController do
  it '#run_get_notification' do
    get 'run_get_notification'
    expect(response).to redirect_to('/')
  end
end
