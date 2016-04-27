require "omniauth-constantcontact2"
OmniAuth.config.logger = Rails.logger
# OmniAuth.config.full_host = Settings.app_host

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :constantcontact, ENV['constant_contact_key'], ENV['constant_contact_secret']
end
