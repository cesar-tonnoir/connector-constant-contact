class Maestrano::Connector::Rails::Entity
  include Maestrano::Connector::Rails::Concerns::Entity

  # Return an array of all the entities that the connector can synchronize
  # If you add new entities, you need to generate
  # a migration to add them to existing organizations
  def self.entities_list
    %w(account contact employee)
  end

  # Return an array of entities from the external app
  def get_external_entities(client, last_synchronization, organization, opts={})
    return [] unless self.class.can_read_external?
    Maestrano::Connector::Rails::ConnectorLogger.log('info', organization, "Fetching #{Maestrano::Connector::Rails::External.external_name} #{self.class.external_entity_name.pluralize}")
    if opts[:full_sync] || last_synchronization.blank? || self.class.no_date_filtering?
      entities = client.all(self.class.external_entity_name, self.class.external_singleton?)
    else
      entities = client.all(self.class.external_entity_name, self.class.external_singleton?, last_synchronization.updated_at)
    end
    Maestrano::Connector::Rails::ConnectorLogger.log('info', organization, "Received data: Source=#{Maestrano::Connector::Rails::External.external_name}, Entity=#{self.class.external_entity_name}, Response=#{entities}")
    entities
  end

  def create_external_entity(client, mapped_connec_entity, external_entity_name, organization)
    Maestrano::Connector::Rails::ConnectorLogger.log('info', organization, "Sending create #{external_entity_name}: #{mapped_connec_entity} to #{Maestrano::Connector::Rails::External.external_name}")
    client.create(external_entity_name, mapped_connec_entity)
  end

  def update_external_entity(client, mapped_connec_entity, external_id, external_entity_name, organization)
    Maestrano::Connector::Rails::ConnectorLogger.log('info', organization, "Sending update #{external_entity_name} (id=#{external_id}): #{mapped_connec_entity} to #{Maestrano::Connector::Rails::External.external_name}")
    client.update(external_entity_name, mapped_connec_entity, external_id)
  end

  def get_connec_entities(client, last_synchronization, organization, opts={})
    # Should find a way to do the same for webhooks
    client.class.headers("CONNEC-COUNTRY-FORMAT"=>'alpha2')
    super
  end

  def self.id_from_external_entity_hash(entity)
    entity['id']
  end

  def self.last_update_date_from_external_entity_hash(entity)
    entity['modified_date'].to_time
  end

  # To be overwritten if needed
  def self.external_singleton?
    false
  end

  def self.no_date_filtering?
    false
  end
end
