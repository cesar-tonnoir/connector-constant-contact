class Maestrano::Connector::Rails::External
  include Maestrano::Connector::Rails::Concerns::External

  def self.external_name
   'ConstantContact'
  end

  def self.get_client(organization)
    # Create New Client
    token = "Bearer " + organization.oauth_token
    ConstantContactClient.new(ENV[:constantcontact_key], token)
  end
end
