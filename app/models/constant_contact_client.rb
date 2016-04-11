class ConstantContactClient
  include HTTParty

  base_uri 'https://api.constantcontact.com/v2/'

  def initialize(api_key, token)
    @api_key = api_key
    @headers = {}
    @headers["Authorization"] = token
  end

  def all(external_entity_name)
    arr = []
    url = get_entity_url(external_entity_name)
    data = self.class.get("#{url}?api_key=#{@api_key}", :headers => @headers)
    external_entity_name == "Account" ? arr << data : data['results']
  end

  def create(external_entity_name, entity)
    url = get_entity_url(external_entity_name)
    self.class.post("#{url}?api_key=#{@api_key}", :headers => @headers, :body => entity.json)
  end

  def update(external_entity_name, entity, id)
    url = get_entity_url(external_entity_name)
    self.class.put("#{url}/#{id}=#{@api_key}", :headers => @headers.json)
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
end
