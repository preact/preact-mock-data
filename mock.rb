require 'preact'
require 'demode'

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

args = ARGV.drop(2)

Preact.configure do |config|
  config.code = ARGV[0]
  config.secret = ARGV[1]
  config.request_timeout = nil
end

event_names = [
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

event_names_count = event_names.count

accounts = []
logs = []

50.times do |n|
  account = { 
    name: Demode::Generator.company_name(n),
    id: n,
    people: []
  }
  accounts << account
end
accounts.each do |account|
  time_offset = 0
  ((account[:id]%10)+1).times do |n|
    person = {
      name: Demode::Generator.name((account[:id]*1000) + n*100),
      email: Demode::Generator.email((account[:id]*1000) + n*100),
      #events: []
    }
    account[:people] << person
  end
  # event_multiplier will default to 1, and won't be less than 1
  event_multiplier = args.first.to_i || 1
  event_multiplier = [event_multiplier, 1].max
  k = rand((10 * event_multiplier)..(90 * event_multiplier))
  k_init_half = k/2 + 1
  while k > 1 do
    account[:people].each do |person|
      # no person should have more than half of the potential events for an account
      j = rand([k,k_init_half].min)
      j.times do
        event = {
          name: event_names[rand(event_names_count)],
          timestamp: Time.now.to_i - ((rand(event_multiplier * 2)) * 24 * 3600) + time_offset
        }
        logs << { person: person, event: event, account: account }
        time_offset += 1
      end
      k = k - j 
    end
  end
end

logs.sort! {|x,y| x[:event][:timestamp]<=>y[:event][:timestamp]}
logs.each do |log|
  Preact.log_event(log[:person], log[:event], log[:account])
end

puts "FINISHED, IGNORE ALL ERRORS AFTER THIS"
# Preact.log_event(
#   { :email       => "gooley@preact.com",
#     :name        => "Christopher Gooley",
#     :created_at  => 1367259292,
#     :uid         => "gooley"
#   }, {
#     :name        => "registered"
#   }
# )