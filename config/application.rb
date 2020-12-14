require_relative 'boot'

require 'rails/all'
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

TERMS = {}

module CuScheduling
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
	config.load_defaults 5.1

	# Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
	# -- all .rb files in that directory are automatically loaded.
	config.time_zone = 'Eastern Time (US & Canada)'
 	config.active_record.default_timezone = :local # Or :utc
	
	config.after_initialize do
		ActiveRecord::Lecture.connection.execute("END;")
		ActiveRecord::Tutorial.connection.execute("END;")
		# comment out to stop rewriting db
		UpdateCoursesJob.perform_later

		scheduler = Rufus::Scheduler.new 
		scheduler.interval "3h" do #also scrape every day
			begin
				UpdateCoursesJob.perform_later
			rescue
				puts "Error scraping data"
			end
		end
	end

  end
end
