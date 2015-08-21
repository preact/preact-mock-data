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

    @account_owner_names = [
      "George Washington",
      "John Adams",
      "John Kennedy",
      "Wilson Phillips"
    ]

    @account_templates = [
      [4, { license_status: ["Active", "Active", "Active", "Cancelled"], 
            license_mrr: [9, 99, 99, 499, 499, 999], 
            license_type: ["Annual"], 
            account_manager_name: @account_manager_names, 
            account_owner_name: @account_owner_names, 
            trial_end: 12.times.map{ |i| ago(i, MONTHS) }, 
            license_renewal: 52.times.map{ |i| from_now(i, WEEKS) } 
          }],
      [4, { license_status: ["Active", "Active", "Active", "Cancelled"], 
            license_mrr: [9, 99, 99, 499, 499, 999], 
            license_type: ["Monthly"], 
            account_manager_name: @account_manager_names, 
            account_owner_name: @account_owner_names, 
            trial_end: 12.times.map{ |i| ago(i, MONTHS) }, 
            license_renewal: 30.times.map{ |i| from_now(i, DAYS) } 
          }],
      [1, { license_status: "Trial", 
            trial_end: 14.times.map{ |i| from_now(i, DAYS) } 
          }]
    ]

    if defaults && defaults.is_a?(Hash)
      defaults.each do |k,v|
        instance_variable_set("@#{k}", v) unless v.nil?
      end
    end
  end

  DAYS = 3600*24
  WEEKS = DAYS * 7
  MONTHS = WEEKS * 4

  def from_now(i, incr)
    Time.now + i * incr
  end

  def ago(i, incr)
    Time.now - i * incr
  end

  def update_accounts
    account_report = JSON.parse(RestClient.get "https://#{@code}:#{@secret}@secure.preact.com/api/v2/reports/53514b8f4443ae11f3000001/list?limit=5000", {:accept => :json})

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