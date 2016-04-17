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

  def get_external_entities(client, last_synchronization, organization, opts={})
    @lists = client.all('List')
    super
  end

  def map_to_external(entity, organization)
    mapped_entity = super
    # Need to specifiy at least one contact list
    mapped_entity.merge(lists: [id: @lists.first["id"]])
  end

  def get_connec_entities(client, last_synchronization, organization, opts={})
    super(client, last_synchronization, organization, opts) #TODO filter people with emails only
    # super(client, last_synchronization, organization, opts.merge(:$filter => "type eq 'MANUAL'")) #change the filter
  end

  def self.object_name_from_connec_entity_hash(entity)
    "#{entity['first_name']} #{entity['last_name']}"
  end

  def self.object_name_from_external_entity_hash(entity)
    "#{entity['first_name']} #{entity['last_name']}"
  end

end

class NoteMapper
  extend HashMapper

  map from('id'), to('id')
  map from('description'), to('note')
end

class PersonMapper
  extend HashMapper

  # TODO: find_or_create in connec!
  # company_name

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

  map from('address_work/billing/line1'), to('addresses[0]/line1')
  map from('address_work/billing/line2'), to('addresses[0]/line2')
  map from('address_work/billing/city'), to('addresses[0]/city')
  map from('address_work/billing/region'), to('addresses[0]/state')
  map from('address_work/billing/postal_code'), to('addresses[0]/postal_code')
  map from('address_work/billing/country'), to('addresses[0]/country_code')

  map from('email/address'), to('email_addresses[0]/email_address')

  map from('phone_work/landline'), to('work_phone')
  map from('phone_home/landline'), to('home_phone')
  map from('phone_home/mobile'), to('cell_phone')
  map from('phone_home/fax'), to('fax')

  map from('notes'), to('note'), using: NoteMapper
end
