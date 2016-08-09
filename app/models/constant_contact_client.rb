class ConstantContactClient
  include HTTParty

  base_uri 'https://api.constantcontact.com'

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
    @headers['Authorization'] = token
    @headers['Content-Type'] = 'application/json'
  end

  def all(entity_name, singleton, modified_since=nil)
    begin
      query_params = {api_key: @api_key}
      if modified_since
        query_params.merge!(modified_since: modified_since.iso8601)
      end
      
      response = self.class.get("#{endpoint(entity_name)}?#{query_params.to_query}", :headers => @headers)
      raise "No response received" unless response && !response.body.blank?
      
      response = JSON.parse(response.body)
      Rails.logger.debug "Client fetch first page #{entity_name}. Response=#{response}"

      if singleton
        raise "Unexpected response: #{response.first['error_message']}" if response.is_a?(Array) && response.first['error_message']
        return [response]
      end
      return response if response.kind_of?(Array)
      raise "Unexpected response: #{response}" unless response.kind_of?(Hash) && response['results']

      entities = response['results']

      while response['meta'] && response['meta']['pagination'] && response['meta']['pagination']['next_link']
        response = self.class.get("#{response['meta']['pagination']['next_link']}&api_key=#{@api_key}", :headers => @headers)
        response = JSON.parse(response.body)
        Rails.logger.debug "Client fetch subsequent pages #{entity_name}. Response=#{response}"
        entities << response['results']
      end

      entities.flatten!
      entities
    rescue => e
      Rails.logger.warn "Error while fetching #{entity_name}: #{e}"
      raise "Error while fetching #{entity_name}: #{e}"
    end
  end

  def create(entity_name, entity)
    begin
      response = self.class.post("#{endpoint(entity_name)}?api_key=#{@api_key}", :headers => @headers, :body => entity.to_json)
      raise "No response received" unless response && !response.body.blank?
      response = JSON.parse(response.body)

      if response.kind_of?(Hash) && response['id']
        response
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
      response = self.class.put("#{endpoint(entity_name)}/#{id}?api_key=#{@api_key}", :headers => @headers, :body => entity.to_json)
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
    def endpoint(entity_name)
      endpoint = {
        'Contact' => '/v2/contacts', 
        'Event' => '/v2/eventspot/events', 
        'Account' => '/v2/account/info', 
        'List' => '/v2/lists', 
      }[entity_name]
      raise 'Unknow endpoint' unless endpoint
      endpoint
    end
end
