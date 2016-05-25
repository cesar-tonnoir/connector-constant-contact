class Maestrano::Connector::Rails::External
  include Maestrano::Connector::Rails::Concerns::External

  # Return an array of all the entities that the connector can synchronize
  # If you add new entities, you need to generate
  # a migration to add them to existing organizations
  def self.entities_list
    %w(account contact employee)
  end

  def self.external_name
   'Constant Contact'
  end

  def self.get_client(organization)
    token = "Bearer " + organization.oauth_token
    ConstantContactClient.new(ENV['constant_contact_key'], token)
  end
end
