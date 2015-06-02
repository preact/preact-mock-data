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

Preact.configure do |config|
	config.code = "b27tfenqea"
	config.secret = "jh9xd2m3yx"
end

accounts = []
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
ARGV.each do|time|
	50.times do |n|
		account = { 
			name: Demode::Generator.company_name(n),
			id: n,
			people: []
		}
		accounts << account
	end

	accounts.each do |account|
		((account[:id]%10)+1).times do |n|
			person = {
				name: Demode::Generator.name((account[:id]*100) + n),
				email: Demode::Generator.email((account[:id]*100) + n),
				#events: []
			}
			account[:people] << person
		end
		k = rand(100)
		account[:people].each do |person|
			if k > 0
				j = rand(k)
				j.times do
					event = {
						name: event_names[rand(14)],
						timestamp: time
					}
					Preact.log_event(person, event, account)
					#person[:events] << event
				end
				k = k - j 
			end
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