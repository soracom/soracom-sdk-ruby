# coding: utf-8
module Soracom
  # 'rest-client' gem like class
  class RestClient
    def self.request(verb, url, headers = {}, payload = nil)
      payload = payload.to_json if payload.class == Hash
      query_string = ''
      if headers[:params]
        query_string = '?' + headers[:params].map { |k, v| "#{k}=#{v}" }.join('&')
        headers.delete(:params)
      end
      headers = Hash[headers.map { |k, v| [k.to_s.capitalize.tr('_', '-'), v] }]
      uri = URI(url + query_string)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'
      http.set_debug_output($stderr) if ENV['SORACOM_DEBUG']
      case verb
      when 'get'
        response = http.get(uri.path + query_string, headers)
      when 'post'
        response = http.post(uri.path + query_string, payload, headers)
      when 'put'
        response = http.put(uri.path + query_string, payload, headers)
      when 'delete'
        response = http.delete(uri.path + query_string, headers)
      else
        fail "unsupported HTTP verb #{verb}"
      end
      response
    end

    def self.get(url, headers = {})
      request('get', url, headers)
    end

    def self.post(url, payload, headers = {})
      request('post', url, headers, payload)
    end

    def self.put(url, payload, headers = {})
      request('put', url, headers, payload)
    end

    def self.delete(url, headers = {})
      request('delete', url, headers)
    end
  end
end
