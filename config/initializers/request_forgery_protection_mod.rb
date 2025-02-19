module ActionController::RequestForgeryProtection
  protected

  def handle_unverified_request
    raise ActionController::InvalidAuthenticityToken, 'You submitted a form with an outdated or missing authenticity token. Try reloading the page you just submitted and submit the form again.'
  end
end
