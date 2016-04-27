class ConstantContactClient
  include HTTParty

  base_uri 'https://api.constantcontact.com/v2/'

  def initialize(api_key, token)
    @api_key = api_key
    @headers = {}
    @headers["Authorization"] = token
    @headers["Content-Type"] = "application/json"
  end

  def all(entity_name, singleton?, modified_since=nil)
    entity_params = get_entity_params(entity_name)
    query_params = entity_params[:query_params] || {}
    query_params.merge!(api_key: @api_key)
    if modified_since
      query_params.merge!(modified_since: modified_since.iso8601)
    end
    data = self.class.get("#{entity_params[:endpoint]}?query_params.to_query", :headers => @headers)
    
    singleton? ? [data] : data['results']
  end

  def create(entity_name, entity)
    endpoint = get_entity_params(entity_name)[:endpoint]
    self.class.post("#{url}?api_key=#{@api_key}", :headers => @headers, :body => entity.to_json)
  end

  def update(entity_name, entity, id)
    endpoint = get_entity_params(entity_name)[:endpoint]
    self.class.put("#{url}/#{id}?api_key=#{@api_key}", :headers => @headers, :body => entity.to_json)
  end
  
  # def modify_entity_for_event_creation(entity)
  #   grp_id = Maestrano::Connector::Rails::Organization.first.uid
  #   maestrano_client = Maestrano::Connec::Client.new(grp_id)
  #   venue_detail = maestrano_client.get("/venues/#{entity[:venue_id]}")["venues"]
  #   entity[:type] = "OTHER"
  #   entity[:name] = venue_detail["name"]
  #   entity[:title] = venue_detail["name"]
  #   entity[:location] = venue_detail["name"]
  #   entity[:time_zone_id] = "US/Eastern"
  #   entity[:address] = {}
  #   entity[:address][:city] = venue_detail["address"]["city"]
  #   entity[:address][:state] = venue_detail["address"]["region"]
  #   entity[:address][:country] = venue_detail["address"]["region"]
  #   entity[:address][:line1] = venue_detail["address"]["line1"]
  #   entity[:address][:line2] = venue_detail["address"]["line2"]
  #   entity[:address][:state_code] = ""
  #   entity[:address][:country_code] = ""
  #   entity[:address][:postal_code] = venue_detail["address"]["postal_code"]
  #   entity[:contact] = {}
  #   entity[:contact][:name] = Maestrano::Connector::Rails::Organization.first.oauth_uid
  #   entity[:contact][:organization_name] = Maestrano::Connector::Rails::Organization.first.name
  #   entity.delete(:venue_id)
  #   entity
  # end

  private
    def get_entity_params(entity_name)
      {
        'Contact' => {endpoint: '/contacts', query_params: {status: 'ACTIVE'}}, 
        'Event' => {endpoint: '/eventspot/events'}, 
        'Account' => {endpoint: '/account/info'}, 
        'List' => {endpoint: '/lists'}, 
      }[entity_name]
    end

end
