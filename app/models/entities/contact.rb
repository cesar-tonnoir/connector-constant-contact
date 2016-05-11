class Entities::Contact < Maestrano::Connector::Rails::Entity

  def self.connec_entity_name
    'Person'
  end

  def self.external_entity_name
    'Contact'
  end

  def self.mapper_class
    ContactMapper
  end

  def before_sync(connec_client, external_client, last_synchronization, organization, opts)
    super
    Maestrano::Connector::Rails::ConnectorLogger.log('info', organization, "Fetching #{Maestrano::Connector::Rails::External.external_name} contact lists")
    all_lists = external_client.all('List', false)
    Maestrano::Connector::Rails::ConnectorLogger.log('info', organization, "Received data: Source=#{Maestrano::Connector::Rails::External.external_name}, Entity=contact lists, Response=#{all_lists}")
    extract_specific_lists(all_lists)
  end

  def map_to_external(entity, organization)
    mapped_entity = super

    # Need to specifiy at least one contact list
    lists = []
    lists << {id: @customer_list['id']} if entity['is_customer'] && @customer_list
    lists << {id: @supplier_list['id']} if entity['is_supplier'] && @supplier_list
    lists << {id: @contact_list['id']} if lists.empty?
    lists.uniq!

    mapped_entity.merge(lists: lists)
  end

  def get_connec_entities(client, last_synchronization, organization, opts={})
    # TODO use Connec! filter when available
    entities = super(client, last_synchronization, organization, opts)
    entities.reject{|e| e['email'].empty?}
  end

  def get_external_entities(client, last_synchronization, organization, opts={})
    entities = super

    # Filtering out contact belonging to the employee list as they are employee and not people in Connec!
    # Performance..
    if @employee_list
      employee_list_id = @employee_list['id']
      entities.reject{|e| e['lists'].find{|list| list['id'] == employee_list_id && list['status'] == 'ACTIVE'}}
    else
      entities
    end
  end

  def self.object_name_from_connec_entity_hash(entity)
    "#{entity['first_name']} #{entity['last_name']}"
  end

  def self.object_name_from_external_entity_hash(entity)
    "#{entity['first_name']} #{entity['last_name']}"
  end

  private
    def extract_specific_lists(all_lists)
      # We could do something smart with some db storage if this is too much of a performance issue
      @customer_list = all_lists.find{|list| list['name'] == 'Customer'}
      @supplier_list = all_lists.find{|list| list['name'] == 'Supplier'}
      @contact_list = all_lists.find{|list| list['name'] == 'Leads and other contacts'} || all_lists.first
      @employee_list = all_lists.find{|list| list['name'] == 'Employee'}
    end
    

end

class NoteMapper
  extend HashMapper

  map from('id'), to('id')
  map from('description'), to('note')
end

class ContactMapper
  extend HashMapper

  # Mapping to constantcontact
  after_normalize do |input, output|
    if output[:addresses] && !output[:addresses].empty?
      output[:addresses].first.merge!(address_type: 'BUSINESS')
    end

    output
  end

  # Mapping to Connec!
  after_denormalize do |input, output|
    output[:notes] = input['notes'].map{|note| NoteMapper.denormalize(note)} if input['notes']

    output[:opts] = {attach_to_organization: input['company_name']} unless input['company_name'].blank?

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
  map from('address_work/billing/country'), to('addresses[0]/country_code'){|country|
    c = ISO3166::Country.find_country_by_name(country) || ISO3166::Country.new(country)
    c ? c.alpha2 : ''
  }

  map from('email/address'), to('email_addresses[0]/email_address')

  map from('phone_work/landline'), to('work_phone')
  map from('phone_home/landline'), to('home_phone')
  map from('phone_home/mobile'), to('cell_phone')
  map from('phone_home/fax'), to('fax')
end
