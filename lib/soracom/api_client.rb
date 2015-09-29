module Soracom
  # Class to handle API requests
  class ApiClient
    def initialize(auth, endpoint)
      @log = Logger.new(STDERR)
      @log.level = ENV['SORACOM_DEBUG'] ? Logger::DEBUG : Logger::WARN
      @auth = auth
      @endpoint = (endpoint.nil?) ? API_BASE_URL : endpoint
    end

    def get(path:'', params:{})
      res = RestClient.get @endpoint + path, accept: 'application/json', params: params, 'X-Soracom-API-Key' => @auth[:apiKey], 'X-Soracom-Token' => @auth[:token]
      return parse(res.body) if res.body && res.body.length > 0
      return { result: (res.code =~ /2../) ? 'success' : 'failure' }
    rescue => evar
      @log.debug evar
      return { result: "failure: #{evar}" }
    end

    def post(path:'', params:{}, payload:{})
      res = RestClient.post @endpoint + path, payload,
                            content_type: 'application/json', accept: 'application/json', params: params, 'X-Soracom-API-Key' => @auth[:apiKey], 'X-Soracom-Token' => @auth[:token]
      return parse(res.body) if res.body && res.body.length > 0
      return { result: (res.code =~ /2../) ? 'success' : 'failure' }
    rescue => evar
      @log.debug evar
      return { result: "failure: #{evar}" }
    end

    def put(path:'', params:{}, payload:{})
      res = RestClient.put @endpoint + path, payload,
                            content_type: 'application/json', accept: 'application/json', params: params, 'X-Soracom-API-Key' => @auth[:apiKey], 'X-Soracom-Token' => @auth[:token]
      return parse(res.body) if res.body && res.body.length > 0
      return { result: (res.code =~ /2../) ? 'success' : 'failure' }
    rescue => evar
      @log.debug evar
      return { result: "failure: #{evar}" }
    end

    def delete(path:'', params:{})
      res = RestClient.delete @endpoint + path, accept: 'application/json', params: params, 'X-Soracom-API-Key' => @auth[:apiKey], 'X-Soracom-Token' => @auth[:token]
      @log.debug res.body
      return parse(res.body) if res.body && res.body.length > 0
      return { result: (res.code =~ /2../) ? 'success' : 'failure' }
    rescue => evar
      @log.debug evar
      return { result: "failure: #{evar}" }
    end

    private

    def parse(response)
      begin
        return JSON.parse(response)
      rescue JSON::ParserError => e
        return {result: response}
      end
    end
  end
end
