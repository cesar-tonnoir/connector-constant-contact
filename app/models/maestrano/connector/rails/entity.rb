class Maestrano::Connector::Rails::Entity
  include Maestrano::Connector::Rails::Concerns::Entity
  # Return an array of all the entities that the connector can synchronize
  # If you add new entities, you need to generate
  # a migration to add them to existing organizations
  def self.entities_list
    # TODO
    # The names in this list should match the names of your entities class
    %w(company person event)
  end

  # Return an array of entities from the external app
  def get_external_entities(client, last_synchronization, organization, opts={})
    return [] unless self.class.can_read_external?
    Maestrano::Connector::Rails::ConnectorLogger.log('info', organization, "Fetching #{Maestrano::Connector::Rails::External.external_name} #{Entities::Company.external_entity_name.pluralize}")
    # This method should return only entities that have been updated since the last_synchronization
    # It should also implements an option to do a full synchronization when opts[:full_sync] == true or when there is no last_synchronization
    if opts[:full_sync] || last_synchronization.blank?
      client.all(self.class.external_entity_name)
    else
      client.all(self.class.external_entity_name, ((last_synchronization.to_date).to_s))
    end
  end

  def create_external_entity(client, mapped_connec_entity, external_entity_name, organization)
    Maestrano::Connector::Rails::ConnectorLogger.log('info', organization, "Sending create #{external_entity_name}: #{mapped_connec_entity} to #{Maestrano::Connector::Rails::External.external_name}")
    # This method creates the entity in the external app and returns the external id
    client.create(external_entity_name, mapped_connec_entity)
  end

  def update_external_entity(client, mapped_connec_entity, external_id, external_entity_name, organization)
    Maestrano::Connector::Rails::ConnectorLogger.log('info', organization, "Sending update #{external_entity_name} (id=#{external_id}): #{mapped_connec_entity} to #{Maestrano::Connector::Rails::External.external_name}")
    # This method updates the entity with the given id in the external app
    client.update(external_entity_name, mapped_connec_entity, external_id)
  end

  def self.id_from_external_entity_hash(entity)
    # This method return the id from an external_entity_hash
    entity['id']
  end

  def self.last_update_date_from_external_entity_hash(entity)
    # This method return the last update date from an external_entity_hash
    entity['modified_date'].to_time || Time.now
  end
end
