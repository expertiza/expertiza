class RegistrationsDecorator
  Lti2Tp::Registration.class_eval do
    include Lti2Commons
    include Signer
    include MessageSupport
    include OAuth::OAuthProxy
  end
end