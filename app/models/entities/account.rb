class Entities::Account < Maestrano::Connector::Rails::Entity

  def self.connec_entity_name
    'Company'
  end

  def self.external_entity_name
    'Account'
  end

  def self.mapper_class
    AccountMapper
  end

  def self.object_name_from_connec_entity_hash(entity)
    "#{entity['name']}"
  end

  def self.object_name_from_external_entity_hash(entity)
    "#{entity['organization_name']}"
  end

  # Entity has no id so we are using email (id for a singleton ressource doesn't matter anyway)
  def self.id_from_external_entity_hash(entity)
    entity['email']
  end

  # No modified_date
  def self.last_update_date_from_external_entity_hash(entity)
    Time.now
  end

  def self.singleton?
    true
  end

  def self.external_singleton?
    true
  end

  def self.no_date_filtering?
    true
  end

end

class AccountMapper
  extend HashMapper

    map from('name'), to('organization_name')
    # TODO something smart with timezones
    # map from('timezone'), to('time_zone')
    map from('email/address'), to('email')

    map from('website/url'), to('website')
    map from('phone/landline'), to('phone')

    map from('address/billing/line1'), to('organization_addresses[0]/line1')
    map from('address/billing/line2'), to('organization_addresses[0]/line2')
    map from('address/billing/city'), to('organization_addresses[0]/city')
    map from('address/billing/postal_code'), to('organization_addresses[0]/postal_code')
    map from('address/billing/country'), to('organization_addresses[0]/country_code')
end
