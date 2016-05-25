class Entities::Employee < Maestrano::Connector::Rails::Entity

  def self.connec_entity_name
    'Employee'
  end

  def self.external_entity_name
    'Contact'
  end

  def self.mapper_class
    EmployeeMapper
  end

  def before_sync(last_synchronization)
    super
    Maestrano::Connector::Rails::ConnectorLogger.log('info', @organization, "Fetching #{Maestrano::Connector::Rails::External.external_name} contact lists")
    all_lists = @external_client.all('List', false)
    Maestrano::Connector::Rails::ConnectorLogger.log('info', @organization, "Received data: Source=#{Maestrano::Connector::Rails::External.external_name}, Entity=contact lists, Response=#{all_lists}")
    # We could do something smart with some db storage if this is too much of a performance issue
    @employee_list = all_lists.find{|list| list['name'] == 'Employee'} || all_lists.first
  end

  def map_to_external(entity)
    mapped_entity = super

    # Need to specifiy at least one contact list
    mapped_entity.merge(lists: [id: @employee_list['id']])
  end

  def filter_connec_entities(entities)
    Entities::Contact.filter_connec_entities(entities)
  end

  def get_connec_entities(last_synchronization)
    # TODO use Connec! filter when available
    entities = super
    filter_connec_entities(entities)
  end

  def self.object_name_from_connec_entity_hash(entity)
    "#{entity['first_name']} #{entity['last_name']}"
  end

  # Only pushing employee from Connec! to constant contact
  def self.can_read_external?
    false
  end
end

class EmployeeMapper
  extend HashMapper

  # Mapping to constantcontact
  after_normalize do |input, output|
    if output[:addresses] && !output[:addresses].empty?
      output[:addresses].first.merge!(address_type: 'BUSINESS')
    end

    output
  end
  
  map from('first_name'), to('first_name')
  map from('last_name'), to('last_name'), default: 'Undefined'
  map from('title'), to('prefix_name')

  map from('job_title'), to('job_title')

  map from('address/billing/line1'), to('addresses[0]/line1')
  map from('address/billing/line2'), to('addresses[0]/line2')
  map from('address/billing/city'), to('addresses[0]/city')
  map from('address/billing/region'), to('addresses[0]/state')
  map from('address/billing/postal_code'), to('addresses[0]/postal_code')
  map from('address/billing/country'), to('addresses[0]/country_code'){|country|
    c = ISO3166::Country.find_country_by_name(country) || ISO3166::Country.new(country)
    c ? c.alpha2 : ''
  }

  map from('email/address'), to('email_addresses[0]/email_address')

  map from('phone/landline'), to('work_phone')
  map from('phone/landline2'), to('home_phone')
  map from('phone/mobile'), to('cell_phone')
  map from('phone/fax'), to('fax')
end
