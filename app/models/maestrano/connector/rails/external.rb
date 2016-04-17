class Maestrano::Connector::Rails::External
  include Maestrano::Connector::Rails::Concerns::External

  def self.external_name
   'Constant Contact'
  end

  def self.get_client(organization)
    token = "Bearer " + organization.oauth_token
    ConstantContactClient.new(ENV[:constantcontact_key], token)
  end
end
