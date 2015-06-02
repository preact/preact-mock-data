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
	"logged-in-0",
	"logged-out-0",
	"forgot-password-0",
	"changed-password-0",
	"updated-profile-0",
	"updated-payment-0",
	"created-document-0",
	"uploaded-media-0",
	"modified-dashboard-0",
	"viewed-dashboard-0",
	"logged-in-1",
	"logged-out-1",
	"forgot-password-1",
	"changed-password-1",
	"updated-profile-1",
	"updated-payment-1",
	"created-document-1",
	"uploaded-media-1",
	"modified-dashboard-1",
	"viewed-dashboard-1",
	"logged-in-2",
	"logged-out-2",
	"forgot-password-2",
	"changed-password-2",
	"updated-profile-2",
	"updated-payment-2",
	"created-document-2",
	"uploaded-media-2",
	"modified-dashboard-2",
	"viewed-dashboard-2",
	"logged-in-3",
	"logged-out-3",
	"forgot-password-3",
	"changed-password-3",
	"updated-profile-3",
	"updated-payment-3",
	"created-document-3",
	"uploaded-media-3",
	"modified-dashboard-3",
	"viewed-dashboard-3",
	"logged-in-4",
	"logged-out-4",
	"forgot-password-4",
	"changed-password-4",
	"updated-profile-4",
	"updated-payment-4",
	"created-document-4",
	"uploaded-media-4",
	"modified-dashboard-4",
	"viewed-dashboard-4",
	"logged-in-5",
	"logged-out-5",
	"forgot-password-5",
	"changed-password-5",
	"updated-profile-5",
	"updated-payment-5",
	"created-document-5",
	"uploaded-media-5",
	"modified-dashboard-5",
	"viewed-dashboard-5",
	"logged-in-6",
	"logged-out-6",
	"forgot-password-6",
	"changed-password-6",
	"updated-profile-6",
	"updated-payment-6",
	"created-document-6",
	"uploaded-media-6",
	"modified-dashboard-6",
	"viewed-dashboard-6",
	"logged-in-7",
	"logged-out-7",
	"forgot-password-7",
	"changed-password-7",
	"updated-profile-7",
	"updated-payment-7",
	"created-document-7",
	"uploaded-media-7",
	"modified-dashboard-7",
	"viewed-dashboard-7",
	"logged-in-8",
	"logged-out-8",
	"forgot-password-8",
	"changed-password-8",
	"updated-profile-8",
	"updated-payment-8",
	"created-document-8",
	"uploaded-media-8",
	"modified-dashboard-8",
	"viewed-dashboard-8",
	"logged-in-9",
	"logged-out-9",
	"forgot-password-9",
	"changed-password-9",
	"updated-profile-9",
	"updated-payment-9",
	"created-document-9",
	"uploaded-media-9",
	"modified-dashboard-9",
	"viewed-dashboard-9"
]

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
			events: []
		}
		account[:people] << person
	end
	k = 100
	account[:people].each do |person|
		if k > 0
			j = rand(k)
			j.times do |o|
				event = {
					name: event_names[k - j + o]
				}
				puts "hello"
				Preact.log_event(person, event, account)
				#person[:events] << event
			end
			k = k - j 
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