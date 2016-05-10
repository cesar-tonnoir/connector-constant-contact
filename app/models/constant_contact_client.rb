class ConstantContactClient
  include HTTParty

  base_uri 'https://api.constantcontact.com/v2/'

  def self.create_contact_lists(organization)
    Maestrano::Connector::Rails::ConnectorLogger.log('info', organization, "Creating contact lists: start")
    client = Maestrano::Connector::Rails::External.get_client(organization)

    lists = client.all('List', false)
    lists_name = lists.map{|list| list['name']}

    (['Customer', 'Supplier', 'Leads and other contacts', 'Employee'] - lists_name).each do |name|
      client.create('List', {name: name, status: 'ACTIVE'})
    end
    Maestrano::Connector::Rails::ConnectorLogger.log('info', organization, "Creating contact lists: end")
  end

  def initialize(api_key, token)
    @api_key = api_key
    @headers = {}
    @headers["Authorization"] = token
    @headers["Content-Type"] = "application/json"
  end

  # TODO pagination
  def all(entity_name, singleton, modified_since=nil)
    begin
      entity_params = get_entity_params(entity_name)
      query_params = entity_params[:query_params] || {}
      query_params.merge!(api_key: @api_key)
      if modified_since
        query_params.merge!(modified_since: modified_since.iso8601)
      end
      response = self.class.get("#{entity_params[:endpoint]}?#{query_params.to_query}", :headers => @headers)
      raise "No response received" unless response && !response.body.blank?
      response = JSON.parse(response.body)
      Rails.logger.debug "Client fetch #{entity_name}. Response=#{response}"

      if singleton
        [response]
      else
        # Depending on the endpoint, response may be an array or a hash with a 'results' key
        if response.kind_of?(Hash) && response['results']
          response['results']
        elsif response.kind_of?(Array)
          response
        else
          raise "Unexpected response: #{response}"
        end
      end
    rescue => e
      Rails.logger.warn "Error while fetching #{entity_name}: #{e}"
      raise "Error while fetching #{entity_name}: #{e}"
    end
  end

  def create(entity_name, entity)
    begin
      endpoint = get_entity_params(entity_name)[:endpoint]
      response = self.class.post("#{endpoint}?api_key=#{@api_key}", :headers => @headers, :body => entity.to_json)
      raise "No response received" unless response && !response.body.blank?
      response = JSON.parse(response.body)

      if response.kind_of?(Hash) && response['id']
        response['id']
      else
        raise "Bad response: #{response}"
      end
    rescue => e
      Rails.logger.warn "Error while creating #{entity_name}: #{e}"
      raise "Error while creating #{entity_name}: #{e}"
    end
  end

  def update(entity_name, entity, id)
    begin
      endpoint = get_entity_params(entity_name)[:endpoint]
      response = self.class.put("#{endpoint}/#{id}?api_key=#{@api_key}", :headers => @headers, :body => entity.to_json)
      raise "No response received" unless response && !response.body.blank?
      response = JSON.parse(response.body)
      raise "Response contains error: #{response}" if response.kind_of?(Array)
      response
    rescue => e
      Rails.logger.warn "Error while updating #{entity_name} (id: #{id}): #{e}"
      raise "Error while updating #{entity_name} (id: #{id}): #{e}"
    end
  end
  
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
