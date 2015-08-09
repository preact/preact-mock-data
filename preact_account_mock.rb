require 'preact'
require 'rest-client'

class PreactAccountMock
  
  def initialize(code, secret, configuration = {}, defaults= {})
    @code = code
    @secret = secret
    ::Preact.configure do |config|
      config.code = code
      config.secret = secret
      config.request_timeout = nil
      config.scheme = configuration[:scheme] if configuration[:scheme] 
      config.host = configuration[:host] if configuration[:host] 
    end
    
    @account_manager_names = [
      "John Smith",
      "James Bridger",
      "Sam Jackson",
      "Tom Wilson",
      "Billy McCool"
    ]

    @account_templates = [
      [3, { license_status: ["Active", "Cancelled"], license_mrr: [9, 99, 99, 499], license_type: ["Monthly", "Monthly", "Annual"], account_manager_name: @account_manager_names }],
      [1, { license_status: "Trial"}]
    ]

    if defaults && defaults.is_a?(Hash)
      defaults.each do |k,v|
        instance_variable_set("@#{k}", v) unless v.nil?
      end
    end
  end

  def update_accounts
    account_report = JSON.parse(RestClient.get "https://#{@code}:#{@secret}@secure.preact.com/api/v2/reports/53514b8f4443ae11f3000001/list", {:accept => :json})

    accounts = account_report['results'].map do |a|
      account = { id: a['external_identifier'] }.merge(get_random_account_properties)
      ::Preact.log_account_event({ name: '___update' }, account)
    end
  end

  def get_random_account_properties
    templates = []
    @account_templates.each{ |i, v| i.times.each{ templates << v } }

    template = templates[rand(templates.length)]

    props = Hash[template.map do |k,v|
      [k, v.is_a?(Array) ? v[rand(v.length)] : v]
    end]
  end

end

module Preact 
  class << self
    protected
    def send_log(person, event=nil)
      psn = person.nil? ? nil : person.to_hash
      evt = event.nil? ? nil : event.to_hash

      print "."
      ::Preact.client.create_event(psn, evt)
    end 
  end
end