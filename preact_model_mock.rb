require 'preact'
require 'demode'

class PreactModelMock
  
  def initialize(code, secret, configuration = {}, defaults= {})
    ::Preact.configure do |config|
      config.code = code
      config.secret = secret
      config.request_timeout = nil
      config.scheme = configuration[:scheme] if configuration[:scheme] 
      config.host = configuration[:host] if configuration[:host] 
    end
    
    @event_names = [
      "logged-in",
      "logged-out",
      "forgot-password",
      "changed-password",
      "updated-profile",
      "updated-payment",
      "created-document",
      "uploaded-media",
      "modified-dashboard",
      "viewed-dashboard",
      "purchased-item",
      "changed-login",
      "created-profile",
      "downgraded",
      "upgraded",
      "signed-up"
    ]
    @account_num = 50
    @person_num = 10
    @event_multiplier = 2

    if defaults && defaults.is_a?(Hash)
      defaults.each do |k,v|
        instance_variable_set("@#{k}", v) unless v.nil?
      end
    end
  end

  def self.generate_accounts(account_num)
    accounts = []
    account_num.times do |n|
      account = { 
        name: Demode::Generator.company_name(n),
        id: n,
        people: []
      }
      accounts << account
    end
    accounts
  end

  def self.generate_people(person_num, multiplier = 1)
    people = []
    person_num.times do |n|
      person = {
        name: Demode::Generator.name((multiplier*10) + n*900),
        email: Demode::Generator.email((multiplier*10) + n*900),
      }
      people << person
    end
    people
  end

  def self.log_events(logs)
  	logs.flatten!(1)
    logs.sort! {|x,y| x[:event][:timestamp]<=>y[:event][:timestamp]}
    logs.each do |log|
      ::Preact.log_event(log[:person], log[:event], log[:account])
    end
    puts "RUNNING, IGNORE ALL ERRORS AFTER THIS"
  end

  def generate_random_account_events(account, event_names_count)
    # To not have multiple events at the exact same time
    time_offset = 0
    logs = []
    #Will set event_max to at least 10*multiplier
    event_max = rand((10 * @event_multiplier)..(100 * @event_multiplier))
    event_max_init_half = event_max/2 + 1
    while event_max > 1 do
      account[:people].each do |person|
        # no person should have more than half of the potential events for an account
        person_events = rand([event_max, event_max_init_half].min)
        person_events.times do
          event = {
            name: @event_names[rand(event_names_count)],
            # Sets timestamp to a random subset of days, offset by time_offset
            timestamp: Time.now.to_i - ((rand(@event_multiplier * 2)) * 24 * 3600) + time_offset
          }
          logs << { person: person, event: event, account: account }
          time_offset += 1
        end
        event_max = event_max - person_events 
      end
    end
    logs  
  end

  def generate_batch
    accounts = []
    logs = []
    accounts = PreactModelMock.generate_accounts(@account_num)
    event_names_count = @event_names.count
    accounts.each do |account|
      #Will vary the person number per account the same every execution
      account[:people] = PreactModelMock.generate_people(((account[:id] % @person_num) + 1), account[:id])
      logs << generate_random_account_events(account, event_names_count)
    end
    PreactModelMock.log_events(logs)
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
# Preact.log_event(
#   { :email       => "gooley@preact.com",
#     :name        => "Christopher Gooley",
#     :created_at  => 1367259292,
#     :uid         => "gooley"
#   }, {
#     :name        => "registered"
#   }
# )
