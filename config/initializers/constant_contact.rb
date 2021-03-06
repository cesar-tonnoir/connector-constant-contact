ConstantContact::Util::Config.configure do |config|
  config[:auth][:api_key] = ENV['constant_contact_key']
  config[:auth][:api_secret] = ENV['constant_contact_secret']
  config[:auth][:redirect_uri] = Settings.app_host + '/auth/constantcontact/callback'
end