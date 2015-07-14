require 'preact'
require 'demode'

class Mock
  module Preact 
    class << self
      protected
      def send_log(person, event=nil)
        psn = person.nil? ? nil : person.to_hash
        evt = event.nil? ? nil : event.to_hash

        if defined?(Preact::Sidekiq) && (configuration.logging_mode.nil? || configuration.logging_mode == :sidekiq)
          Preact::Sidekiq::PreactLoggingWorker.perform_async(psn, evt)
        else
          # use the background thread logger
          Preact::BackgroundLogger.new.perform(psn, evt)
        end
      end 
    end
  end
  
  def initialize(code, secret, configuration={}, defaults={})
    Preact.configure do |config|
      config.code = code
      config.secret = secret
      config.request_timeout = nil
      if configuration[:scheme] { config.scheme = configuration[:scheme] }
      if configuration[:host] { config.host = configuration[:host] }
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
      hash.each do |k,v|
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
  end

  def self.generate_people(person_num, multiplier = 1)
    people = []
    person_num.times do |n|
      person = {
        name: Demode::Generator.name((multiplier*1000) + n*99),
        email: Demode::Generator.email((multiplier*1000) + n*99),
      }
      people << person
    end
  end

  def generate_random_account_events(account, event_names_count)
    time_offset = 0
    logs = []
    k = rand((10 * @event_multiplier)..(100 * @event_multiplier))
    k_init_half = k/2 + 1
    while k > 1 do
      account[:people].each do |person|
        # no person should have more than half of the potential events for an account
        j = rand([k,k_init_half].min)
        j.times do
          event = {
            name: @event_names[rand(event_names_count)],
            timestamp: Time.now.to_i - ((rand(@event_multiplier * 2)) * 24 * 3600) + time_offset
          }
          logs << { person: person, event: event, account: account }
          time_offset += 1
        end
        k = k - j 
      end
    end
    logs  
  end

  def self.log_events(logs)
    logs.sort! {|x,y| x[:event][:timestamp]<=>y[:event][:timestamp]}
    logs.each do |log|
      Preact.log_event(log[:person], log[:event], log[:account])
    end
    puts "FINISHED, IGNORE ALL ERRORS AFTER THIS"
  end

  def generate_batch
    accounts = []
    logs = []
    accounts = Mock.generate_accounts(@account_num)
    event_names_count = @event_names.count
    accounts.each do |account|
      account[:people] = Mock.generate_people(((account[:id] % @person_num) + 1), account[:id])
      logs << generate_random_account_events(account, event_names_count)
    end
    Mock.log_events(logs)
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
end