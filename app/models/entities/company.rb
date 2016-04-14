class Entities::Company < Maestrano::Connector::Rails::Entity

  def self.connec_entity_name
    'Company'
  end

  def self.external_entity_name
    'Account'
  end

  def self.mapper_class
    CompanyMapper
  end

  def self.singleton?
    true
  end

  def self.id_from_external_entity_hash(entity)
    # This method return the id from an external_entity_hash
    entity['email']
  end

  def self.object_name_from_connec_entity_hash(entity)
    "#{entity['name']}"
  end

  def self.object_name_from_external_entity_hash(entity)
    "#{entity['organization_name']}"
  end

  def self.last_update_date_from_external_entity_hash(entity)
    Time.now
  end

end

class CompanyMapper
  extend HashMapper
    map from('/name'), to('/organization_name')
    map from('/timezone'), to('/timezone')
    map from('/email/address'), to('/email')

    map from('/website/url'), to('/domain')
    map from('/phone/landline'), to('/phone')

    map from('/address/billing/line1'), to('/address1')
    map from('/address/billing/city'), to('/city')
    map from('/address/billing/region'), to('/province')
    map from('/address/billing/postal_code'), to('/zip')
    map from('/address/billing/country'), to('/country_code')
    map from('/currency'), to('/currency')
end
