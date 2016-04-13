class ConstantContactClient
  include HTTParty

  base_uri 'https://api.constantcontact.com/v2/'

  def initialize(api_key, token)
    @api_key = api_key
    @headers = {}
    @headers["Authorization"] = token
    @headers["Content-Type"] = "application/json"
  end

  def all(external_entity_name)
    arr = []
    url = get_entity_url(external_entity_name)
    data = self.class.get("#{url}?api_key=#{@api_key}", :headers => @headers)
    external_entity_name == "Account" ? arr << data : data['results']
  end

  def create(external_entity_name, entity)
    url = get_entity_url(external_entity_name)
    modified_entity = fetch_data(url, entity)
    self.class.post("#{url}?api_key=#{@api_key}", :headers => @headers, :body => modified_entity.to_json)
  end

  def update(external_entity_name, entity, id)
    url = get_entity_url(external_entity_name)
    self.class.put("#{url}/#{id}?api_key=#{@api_key}", :headers => @headers, :body => entity.to_json)
  end

  def modify_entity_for_contact_creation(entity)
    lists = self.class.get("/lists?api_key=#{@api_key}", :headers => @headers)
    entity[:lists][0][:id] = lists.first["id"]
    if entity[:addresses].blank?
      entity[:addresses] = []
      entity[:addresses][0] = {}
    else
      entity[:addresses][0][:country_code] = Entities::Person::COUNTRY_CODES.key(entity[:addresses][0][:country_code])
    end
    entity[:email_addresses][0][:email_address] = "default@yopmail.com" if entity[:email_addresses][0][:email_address].blank?

    entity[:addresses][0][:address_type] = "PERSONAL"
    entity
  end


  def modify_entity_for_event_creation(entity)
    grp_id = Maestrano::Connector::Rails::Organization.first.uid
    maestrano_client = Maestrano::Connec::Client.new(grp_id)
    venue_detail = maestrano_client.get("/venues/#{entity[:venue_id]}")["venues"]
    entity[:type] = "OTHER"
    entity[:title] = venue_detail["name"]
    entity[:location] = venue_detail["name"]
    entity[:time_zone_id] = "US/Eastern"
    entity[:address] = {}
    entity[:address][:city] = venue_detail["address"]["city"]
    entity[:address][:state] = venue_detail["address"]["region"]
    entity[:address][:country] = venue_detail["address"]["region"]
    entity[:address][:line1] = venue_detail["address"]["line1"]
    entity[:address][:line2] = venue_detail["address"]["line2"]
    entity[:address][:state_code] = ""
    entity[:address][:country_code] = ""
    entity[:address][:postal_code] = venue_detail["address"]["postal_code"]
    entity[:contact] = {}
    entity[:contact][:name] = Maestrano::Connector::Rails::Organization.first.oauth_uid
    entity[:contact][:organization_name] = Maestrano::Connector::Rails::Organization.first.name
    entity.delete(:venue_id)
    entity
  end

  private
    def get_entity_url(external_entity_name)
      name = external_entity_name.downcase.pluralize
      case name
        when "contacts"
          "/contacts"
        when "events"
          "/eventspot/events"
        else
          "/account/info"
        end
    end

    def fetch_data(url, entity)
      case url
        when "/contacts"
          modify_entity_for_contact_creation(entity)
        when "/eventspot/events"
          modify_entity_for_event_creation(entity)
        end
    end

end
