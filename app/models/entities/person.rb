class Entities::Person < Maestrano::Connector::Rails::Entity

  def self.connec_entity_name
    'Person'
  end

  def self.external_entity_name
    'Contact'
  end

  def self.mapper_class
    PersonMapper
  end

  def self.object_name_from_connec_entity_hash(entity)
    "#{entity['first_name']} #{entity['last_name']}"
  end

  def self.object_name_from_external_entity_hash(entity)
    "#{entity['FirstName']} #{entity['LastName']}"
  end

end

class PersonMapper

  extend HashMapper
  map from('first_name'), to('first_name')
  map from('last_name'), to('last_name'), default: 'Undefined'
  map from('address_work/billing/line1'), to('addresses[0]/address1')
  map from('address_work/billing/line2'), to('addresses[0]/address2')
  map from('address_work/billing/city'), to('addresses[0]/city')
  map from('address_work/billing/region'), to('addresses[0]/state')
  map from('address_work/billing/postal_code'), to('addresses[0]/postal_code')
  map from('address_work/billing/country'), to('addresses[0]/country_code')
  map from('email/address'), to('email')

end
