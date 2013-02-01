module ActionController::RequestForgeryProtection
  protected
    def handle_unverified_request
      raise ActionController::InvalidToken
    end
end
