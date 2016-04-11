class Entities::Event < Maestrano::Connector::Rails::Entity

  def self.connec_entity_name
    'Event'
  end

  def self.external_entity_name
    'Event'
  end

  def self.mapper_class
    EventMapper
  end

  def self.object_name_from_connec_entity_hash(entity)
    "#{entity['name']}"
  end

  def self.object_name_from_external_entity_hash(entity)
    "#{entity['title']}"
  end

end

class EventMapper

  extend HashMapper
  map from('name'), to('name')
  map from('title'), to('title')
  map from('status'), to('status')
  map from('location'), to('location')
  map from('topic'), to('addresses[0]/city')
  map from('created_at'), to('created_at')
  map from('updated_at'), to('updated_at')
end
