require "omniauth-constantcontact2"
OmniAuth.config.logger = Rails.logger
OmniAuth.config.full_host = ENV[:host]# for local use 'http://localhost:3000'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :constantcontact, ENV[:constantcontact_key], ENV[:constantcontact_secret_key]
end
