# Not used
# class Entities::Event < Maestrano::Connector::Rails::Entity

#   def self.connec_entity_name
#     'Event'
#   end

#   def self.external_entity_name
#     'Event'
#   end

#   def self.mapper_class
#     EventMapper
#   end

#   def self.object_name_from_connec_entity_hash(entity)
#     "#{entity["name"]}"
#   end

#   def self.object_name_from_external_entity_hash(entity)
#     "#{entity["name"]}"
#   end

# end

# class EventMapper

#   extend HashMapper
#   map from('name'), to('name')
#   map from('title'), to('title')
#   map from('status'), to('type')
#   map from('location'), to('location')
#   map from('start_date'), to('start_date')
#   map from('end_date'), to('end_date')
#   map from('venue_id'), to('venue_id')
# end
